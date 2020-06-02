export default function (req, res, next) {
    // req は Node.js の HTTPリクエストオブジェクトです
    console.log(req.url)
  
    // res は Node.js の HTTPレスポンスオブジェクトです
  
    // next は 次のミドルウェアを呼び出すための関数です。
    // あなたのミドルウェアが最後でない場合、関数の最後で next を呼び出すのを忘れないでください！
    next()
  }