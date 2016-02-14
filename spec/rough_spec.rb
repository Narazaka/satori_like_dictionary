# coding: utf-8
Encoding.default_external = 'utf-8'

require 'satori_like_dictionary'

dic_str1 = <<-EOM
＊test
：あああ
：ああ

＊test2
aaa
＄kk = 1
aa
%= kk
（１０９）（単語）
＿選択肢 ＿選択肢2　＿still選択肢2 not＿選択肢
＿選択肢4

＊test3
%= request.Reference0

＊test4
：あああ

＞ジャンプ先

＊test5
→さくら
さくらたそ～

＊ジャンプ先
：ジャンプ＋

＊
：ランダムトーク

＠単語
単語<%= 3 - 2 %>
EOM

describe SatoriLikeDictionary do
  let(:request) { OpenStruct.new({Reference0: "ref0"}) }
  before(:each) { dic.parse(dic_str) }

  context "can work standalone" do
    let(:dic) { SatoriLikeDictionary.new }
    let(:dic_str) { dic_str1 }
    subject { dic.talk(id, request) }

    context "：" do
      let(:id) { "test" }
      it { is_expected.to be == '\1\0あああ\n\1ああ' }
    end

    context "various call" do
      let(:id) { "test2" }
      it { is_expected.to be == '\1aaa\naa\n1\n\s[109]単語1\n\q[選択肢,選択肢] \q[選択肢2　＿still選択肢2,選択肢2　＿still選択肢2] not＿選択肢\n\q[選択肢4,選択肢4]' }
    end

    context "context reference" do
      let(:id) { "test3" }
      it { is_expected.to be == '\1ref0' }
    end

    context "jump" do
      let(:id) { "test4" }
      it { is_expected.to be == '\1\0あああ\n\n\1\0ジャンプ＋\e' }
    end

    context "communication" do
      let(:id) { "test5" }
      it { is_expected.to be == OpenStruct.new(Value: '\1さくらたそ～', Reference0: 'さくら') }
    end

    context "aitalk" do
      subject { dic.aitalk(request) }
      it { is_expected.to be == '\1\0ランダムトーク' }
    end
  end
end

describe SatoriLikeDictionaryIntegratedEvents do

  class Events < SatoriLikeDictionaryIntegratedEvents
    def method_missing method_name, request
      talk request, method_name
    end

    def OnAITalk(request)
      aitalk request
    end

    def test3(request)
      talk request
    end

    def ジャンプ先(request)
      talk(request) + "!"
    end
  end

  let(:events) { Events.new }
  let(:request) { OpenStruct.new({Reference0: "ref0"}) }
  before(:each) { events.send :parse_string, dic_str }

  context "can work" do
    let(:dic_str) { dic_str1 }

    context "test" do
      subject { events.test(request) }
      it { is_expected.to be == '\1\0あああ\n\1ああ' }
    end

    context "aitalk" do
      subject { events.OnAITalk(request) }
      it { is_expected.to be == '\1\0ランダムトーク' }
    end

    context "talk called with no method name" do
      subject { events.test3(request) }
      it { is_expected.to be == '\1ref0' }
    end

    context "choice select" do
      let(:request) { OpenStruct.new({Reference0: "test"}) }
      subject { events.OnChoiceSelect(request) }
      it { is_expected.to be == '\1\0あああ\n\1ああ' }
    end

    context "event reference" do
      subject { events.test4(request) }
      it { is_expected.to be == '\1\0あああ\n\n\1\0ジャンプ＋!\e' }
    end

  end
end
