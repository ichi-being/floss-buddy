// このファイルは、新規登録画面で読み込まれる
document.addEventListener('turbo:load', async () => {
  try {
    // csrf-tokenを取得
    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    // LIFF_ID を定数定義
    const LIFF_ID = gon.liff_id;
    // LIFF_IDを使ってLIFFの初期化
    await liff.init({ liffId: LIFF_ID, withLoginOnExternalBrowser: true });
    //  初期化によって取得できるidtokenの定義
    const idToken = liff.getIDToken();
    // bodyにパラメーターの設定
    const body = new URLSearchParams({ idToken }).toString();
    // リクエスト内容の定義
    const request = new Request('/users', {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        'X-CSRF-Token': token
      },
      method: 'POST',
      body: body
    });

    // リクエストを送る
    const response = await fetch(request);
    const responseBody = await response.json();

    // レスポンスのステータスコードがOKではない場合の処理
    if (!response.ok) {
      // IdTokenの有効期限が切れていることを示すエラーを検出する
      if (responseBody.error === 'IdToken expired.') {
        // LIFFのログインプロセスをトリガーして新たなIdTokenを取得する
        liff.login();
        return;
      }
      // その他のエラーの場合は、エラーメッセージを表示する
      console.error('Network response was not ok:', responseBody.error);
      alert('エラーが発生しました。');
      return;
    }

    // レスポンスが正常の場合、LIFFブラウザを閉じるなどの後続処理を行う
    const data_id = responseBody;
    liff.closeWindow();
  } catch (error) {
    console.error(error); // ログにエラーを記録する
    alert('エラーが発生しました。');
  }
});
