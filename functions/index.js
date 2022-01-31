const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const firestore = admin.firestore();

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
        // functions.logger.log(status, status);
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
