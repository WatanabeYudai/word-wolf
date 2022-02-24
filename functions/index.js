const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const firestore = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

/**
 * Realtime Database にユーザーステータスが作成されたとき、
 * Firestore にデータをコピーする。
 */
exports.onUserCreated = functions.database.ref('/users/{uid}').onCreate(
    async (snapshot, context) => {
        const user = snapshot.val();
        const data = {
            id: context.params.uid,
            lastChanged: new Date(user.lastChanged),
            state: user.state,
            currentPlayroom: '',
        };
        const userRef = firestore.collection('users').doc(context.params.uid);
        userRef.set(data);
    }
);

/**
 * Realtime Database のユーザーステータスが更新されたとき、
 * Firebase のデータも更新する。
 */
exports.onUserStatusChanged = functions.database.ref('/users/{uid}').onUpdate(
    async (change, context) => {
        const eventStatus = change.after.val();
        const newStatusSnapshot = await change.after.ref.once('value');
        const newStatus = newStatusSnapshot.val();
        // この処理が実行されるまでの間にデータが更新されていた場合、今回の処理はスキップ。
        if (newStatus.lastChanged > eventStatus.lastChanged) {
            return null;
        }

        const userRef = firestore.collection('users').doc(context.params.uid);
        const newStatusForFirestore = {
            state: newStatus.state,
            lastChanged: new Date(newStatus.lastChanged)
        };
        return userRef.set(newStatusForFirestore, { merge: true });
    }
);

/**
 * ユーザーがオフラインになったとき、
 * 必要に応じてユーザー情報、プレイルーム情報を更新する。
 */
exports.onUserStateChanged = functions.firestore.document('users/{uid}').onUpdate(
    (change, context) => {
        const newStatus = change.after.data();
        const roomId = newStatus.currentPlayroom;
        const playerId = context.params.uid;
        if (newStatus.state === 'offline' && roomId) {
            leavePlayroom(roomId, playerId);
        }
        return null;
    }
);

async function enterPlayroom(playroomId, playerId) {
    const roomRef = firestore.collection('playrooms').doc(playroomId);
    const snapshot = await roomRef.get();
    if (!snapshot.exists) return;
    const room = snapshot.data();
    switch (room.gameState) {
        case 'standby':
            // プレイヤーリストから削除
            removePlayer(room, playerId)
            clearCurrentPlayroom(playerId)
            return;
        case 'playing':
        case 'voting':
        case 'ended':
            // プレイヤーを inactive 化
            inactivatePlayer(room, playerId);
            clearCurrentPlayroom(playerId)
            return;
        default:
            functions.logger.log('No such game state.');
            return;
    }
}

async function leavePlayroom(playroomId, playerId) {
    const roomRef = firestore.collection('playrooms').doc(playroomId)
    const snapshot = await roomRef.get();
    if (!snapshot.exists) {
        functions.logger.log('room does not exist.');
        return;
    }
    const room = snapshot.data();
    switch (room.gameState) {
        case 'standby':
            // プレイヤーリストから削除
            await removePlayer(room.id, playerId)
            await onLeftPlayroom(room, playerId)
            clearCurrentPlayroom(playerId)
            return;
        case 'playing':
        case 'voting':
        case 'ended':
            // プレイヤーを inactive 化
            await inactivatePlayer(room.id, playerId);
            await onLeftPlayroom(room, playerId)
            clearCurrentPlayroom(playerId)
            return;
        default:
            functions.logger.log('No such game state.');
            return;
    }
}

async function removePlayer(playroomId, playerId) {
    functions.logger.log('called removePlayer()');
    const playerRef = firestore
        .collection('playrooms').doc(playroomId)
        .collection('players').doc(playerId);
    await playerRef.delete();
}

async function inactivatePlayer(playroomId, playerId) {
    functions.logger.log('called inactivatePlayer()');
    const playerRef = firestore
        .collection('playrooms').doc(playroomId)
        .collection('players').doc(playerId);
    await playerRef.update({ isActive: false });
}

// TODO: メソッド名検討
async function onLeftPlayroom(playroom, playerId) {
    functions.logger.log('called onLeftPlayroom()');
    const playroomRef = firestore.collection('playrooms').doc(playroom.id)
    const playersRef = playroomRef.collection('players');
    const playersSnapshot = await playersRef.get();
    const activePlayerIds = playersSnapshot.docs
        .filter(doc => doc.data().isActive)
        .map(doc => doc.data().id);

    // 自分以外にアクティブなプレイヤーがいない場合は部屋を閉じる
    if (activePlayerIds.length === 0) {
        playroomRef.set({ isClosed: true }, { merge: true });
        return;
    }
    // TODO: この時点で管理者が変わっていないことを保証できるか？
    const isAdmin = playroom.adminPlayerId === playerId;
    // プレイヤーが管理者だった場合は他のプレイヤーを管理者にする
    if (isAdmin) {
        // TODO: この時点で activePlayerIds[0] のプレイヤーがアクティブだと保証できるか？
        const newAdminId = activePlayerIds[0];
        playroomRef.update({ adminPlayerId: newAdminId });
    }
}

function clearCurrentPlayroom(playerId) {
    functions.logger.log('called clearCurrentPlayroom()');
    const userRef = firestore.collection('users').doc(playerId);
    userRef.set({
        currentPlayroom: '',
        lastChanged: new Date(),
    }, { merge: true });
}
