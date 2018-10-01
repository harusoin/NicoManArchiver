# NicoManArchiver
ニコニコ漫画を一括保存するRubyスクリプトです
## 実行に必要なもの
* ruby
* bundler
* chrome
* chromedriver
## 準備
このリポジトリを適当な場所にダウンロードし、展開し、   
```bundle install --path vendor/bundle```  
を実行。  
OSに合わせて最新の[chromedriver](http://chromedriver.chromium.org)をダウンロードし、NicoManArchiverと同じディレクトリに配置する
## 使い方
```ruby NicoManArchiver.rb --path "保存したい漫画の第一話のURL"```  
を実行することで全話一括保存出来ます。エラーが発生して途中で止まった場合はそのページのURLを指定することでそこから再開します。
## 作者
[@harusoin](https://twitter.com/harusoin51)
## ライセンス
MIT License