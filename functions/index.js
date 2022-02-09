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
        functions.logger.log(user);
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
 * 必要に応じユーザー情報、プレイルーム情報を更新する。
 */
exports.onUserStateChangedToOffline = functions.firestore.document('users/{uid}').onUpdate(
    async (change, context) => {
        const newStatus = change.after.data();
        const roomId = newStatus.currentPlayroom;
        if (newStatus.state === 'offline' && roomId) {
            const roomRef = firestore.collection('playrooms').doc(roomId);
            const room = (await roomRef.get()).data();
            const playerId = context.params.uid;
            switch (room.gameState) {
                case 'standby':
                    // プレイヤーリストから削除
                    removePlayer(room, playerId)
                    clearCurrentPlayroom(playerId)
                    return null;
                case 'playing':
                case 'voting':
                case 'ended':
                    // プレイヤーを inactive 化
                    inactivatePlayer(room, playerId);
                    clearCurrentPlayroom(playerId)
                    return null;
                default:
                    functions.logger.log('No such game state.');
                    return null;
            }
        }
        return null;
    }
);

function removePlayer(playroom, playerId) {
    functions.logger.log('called removePlayer()');
    prepare(playroom, playerId);
    const deletePlayer = {};
    deletePlayer['players.' + playerId] = FieldValue.delete();
    const roomRef = firestore.collection('playrooms').doc(playroom.id);
    roomRef.update(deletePlayer);
}

function inactivatePlayer(playroom, playerId) {
    functions.logger.log('called inactivatePlayer()');
    prepare(playroom, playerId);
    const updatePlayer = {};
    updatePlayer['players.' + playerId + '.isActive'] = false;
    const roomRef = firestore.collection('playrooms').doc(playroom.id);
    roomRef.update(updatePlayer);
}

// TODO: メソッド名検討
function prepare(playroom, playerId) {
    functions.logger.log('called prepare()');
    const roomRef = firestore.collection('playrooms').doc(playroom.id);
    const activePlayerIds = Object.keys(playroom.players).filter(id => {
        return playroom.players[id].isActive
    });
    // 自分以外にアクティブなプレイヤーがいない場合は部屋を閉じる
    if (activePlayerIds.length <= 1) {
      roomRef.set({ isClosed: true }, { merge: true });
      return;
    }
    const isAdmin = playroom.adminPlayerId === playerId;
    // プレイヤーが管理者だった場合は他のプレイヤーを管理者にする
    if (isAdmin) {
        // TODO: この時点で activePlayerIds[0] のプレイヤーがアクティブだと保証できるか？
        newAdminId = activePlayerIds[0]
        roomRef.set({ adminPlayerId: newAdminId }, { merge: true });
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
