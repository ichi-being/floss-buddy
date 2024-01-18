// DOMが読み込まれたら処理が走る
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
    const request = new Request('/user', {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        'X-CSRF-Token': token
      },
      method: 'POST',
      body: body
    });

    // リクエストを送る
    const response = await fetch(request);

    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    // jsonでレスポンスからデータを取得して/after_loginに遷移する
    const data = await response.json();
    const data_id = data;
    window.location = '/after_login';
  } catch (error) {
    console.error(error); // ログにエラーを記録する
    alert('エラーが発生しました。');
  }
});
