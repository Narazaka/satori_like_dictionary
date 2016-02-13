# [SatoriLikeDictionary](https://github.com/Narazaka/satori_like_dictionary)

[![Gem](https://img.shields.io/gem/v/satori_like_dictionary.svg)](https://rubygems.org/gems/satori_like_dictionary)
[![Gem](https://img.shields.io/gem/dtv/satori_like_dictionary.svg)](https://rubygems.org/gems/satori_like_dictionary)
[![Gemnasium](https://gemnasium.com/Narazaka/satori_like_dictionary.svg)](https://gemnasium.com/Narazaka/satori_like_dictionary)
[![Inch CI](http://inch-ci.org/github/Narazaka/satori_like_dictionary.svg)](http://inch-ci.org/github/Narazaka/satori_like_dictionary)
[![Travis Build Status](https://travis-ci.org/Narazaka/satori_like_dictionary.svg)](https://travis-ci.org/Narazaka/satori_like_dictionary)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/Narazaka/satori_like_dictionary?svg=true)](https://ci.appveyor.com/project/Narazaka/satori-like-dictionary)
[![codecov.io](https://codecov.io/github/Narazaka/satori_like_dictionary/coverage.svg?branch=master)](https://codecov.io/github/Narazaka/satori_like_dictionary?branch=master)
[![Code Climate](https://codeclimate.com/github/Narazaka/satori_like_dictionary/badges/gpa.svg)](https://codeclimate.com/github/Narazaka/satori_like_dictionary)

Satori like dictionary for Ukagaka SHIORI subsystems

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'satori_like_dictionary'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install satori_like_dictionary

## Satori Like Dictionary

```
ファイル先頭から最初の＊あるいは＠までコメント

＊OnAITalk
：さくらがわ
：けろがわ
＃コメント
＃コメント行の改行は維持されない（里々と異なる
：わー

＊
：ランダムトーク

＠単語
単語1
単語2
＞などの行頭記号は効果がない

＊
＞指定されたエントリ名へ飛ぶ
＃＞のあとのものは表示されない
ここは表示されない

＊
→さくら
＃話しかける相手を指定（里々と異なる
さくらさん！

＊
＄variable = "aaa"
＃＄はrubyコードを書く（里々と異なる

＊
＿選択肢1
＿選択肢2 ＿選択肢3
＃選択肢は1行ではなく空白までとなった（里々と異なる

＊
（１）（2）（４２）
＃（数字）は\s[数字]に変換

＊
（単語）
＃（文字列）は該当するエントリがある場合それを表示

＊
<%= 1 + 1 %>
＃コードはerb風の表記で記述（里々での「（関数or変数等）」の用法の括弧は消滅

＊
＃erb風の諸々
% num = 42
%= num
<% num *= 2 %>
<%= num %>

＊
：主に利用できる値
%= events.to_s # イベント定義オブジェクト
%= request.Reference0 # リクエストオブジェクト
%= r0 # request.Reference0の短縮表記

＊
：句読点に待ち時間をつけるなど、単純な置換で再現できるものはこのライブラリでは行わない。

```

## API

[API Document](http://www.rubydoc.info/github/Narazaka/satori_like_dictionary)

## License

This is released under [MIT License](http://narazaka.net/license/MIT?2016).
