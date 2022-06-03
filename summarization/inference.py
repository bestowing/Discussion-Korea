import torch
from kobart import get_kobart_tokenizer
from transformers.models.bart import BartForConditionalGeneration

from transformers import PreTrainedTokenizerFast

import pandas as pd

import pprint

import time
import argparse
parser = argparse.ArgumentParser(description='KoBART Summarization inference')

parser.add_argument('--version', type=int, default=4,
                    help="""version1: 일상 + 데이콘 + 사설
                            version2: 일상 + 데이콘 + 사설 + 신문
                            version3: 데이콘 + 사설
                            version4: 데이콘 + 사설 + 신문 """)
parser.add_argument('--epoch',type=int, default=7,
                    help='training epochs')
parser.add_argument('--beam',type=int, default=50,
                    help='number of beam')


def load_model(model_dir=None):
    model = BartForConditionalGeneration.from_pretrained(model_dir)
    return model


device = 'cuda' if torch.cuda.is_available() else "cpu"

tokenizer1 = PreTrainedTokenizerFast.from_pretrained(
    'digit82/kobart-summarization')
model1 = BartForConditionalGeneration.from_pretrained(
    'digit82/kobart-summarization').to(device)

args = parser.parse_args()
# model2 = load_model('./kobart_summary_daily').to(device)
# model2 = load_model('./kobart_summary_only_dacon_epoch49').to(device)
model3 = load_model(f'./kobart_summary_version4_e7').to(device)
model4 = load_model(f'./kobart_summary_version4_e23').to(device)#현재까지 가장 잘하는 듯함
model5 = load_model(f'./kobart_summary_version4_e29').to(device)
model6 = load_model(f'./kobart_summary_version4_e39').to(device)
model7 = load_model(f'./kobart_summary_version4_e49').to(device)

tokenizer2 = get_kobart_tokenizer()


def get_summary(text, model, tokenizer):
    raw_input_ids = tokenizer.encode(text)
    input_ids = [tokenizer.bos_token_id] + \
        raw_input_ids + [tokenizer.eos_token_id]

    summary_ids = model.generate(torch.tensor(
        [input_ids], device=device),  num_beams=args.beam, no_repeat_ngram_size = 2 ,  max_length=1000,  eos_token_id=1)
    result = tokenizer.decode(
        summary_ids.squeeze().tolist(), skip_special_tokens=True)

    result = ''.join(result)
    return result


width = 60
pp = pprint.PrettyPrinter(width=width, compact=False)

text1 ="""법 앞에 왜 누구는 연민의 대상이 되어야 하고, 누구는 연민의 대상이 되지 않아야 하는거지? 이미 이거 자체가 법의 공정성에 심각한 문제가 되는 논점인건데. 법의 공정성이 무너진다면 그 판결과 그 판결을 한 인간의 저의를 의심받을 수 밖에 없는건데, 무슨 인정할 수 없는 결과의 초래를 이야기하는지 모르겠음. 약자에게 관대하고, 강제에게 엄격한 건 법이 아니고, 이미 그 자체로 법이 아니라 처벌로 규정하는 게 맞는거임.  예를 들어, 어린 아이를 먹이기 위해 부모가 빵을 훔치건 연민을 느껴 처벌을 느슨하게 해야 된다고 주장하는 측면에서 생각해보면 빵집 주인은 장사가 안 되서 오늘 내일 망할 상황이라 자기 자식도 똑같이 못 먹는 처지와 빚에 허덕인다고 하면 여기서 법은 누구를 약자로 보고 연민으로 판단을 해야 되는 거임?  연민의 영역을 법의 잣대에 들이대는 순간부터 사회 공동체 유지를 위해 만든 법을 무너뜨리는 행위를 하는 거밖에 안되는거임. 연민이라는 건 말 그대로 도덕적이거나 윤리적인 관점에서 가져야 하는 기준인거지 법에서 이야기할 논점은 아니라는 거임."""
# text2 ="""인공지능의 레벨이 요점인 것 같은데  난 인간의 모든 의식활동은 알고리즘이라 생각함결국 감정적이고 모호한 부분까지 원칙으로 설명될 날이 올거라 기대하고있음  그 정도 단계가 된다면 아니 더 낮은 단계여도 무조건적으로 채용해야된다고 본다  애초에 어떤 시험 기준으로 판검사를 뽑는건지도 이해할 수가 없고그 자격 시험이 실제로 공정한 판결을 낼 수있는 법관을 양성 할 수 있다면인공지능도 합격할 시에 전혀 문제 될게 없지않나  삼심제를 한다는것부터 일단 인간이 판가름하는데 있어 불안정하다고 말하는것이고어떤 판사한테 재판받느냐에 판결이 달라지는게 말이 안되는거지  물론 현재로서는 불가능하지만 재판관이 판결하는데 있어 참고하고어느정도 결과에 영향을 줄 수 있는 수준까지 거쳐서  결국에는 완벽하게 대체될 거라 생각함"""
# text3 ="""저는 초,중등학교 9시 등교 시행 필요한 정책인가? 라는 논제에 찬성합니다.그 이유는 첫째, 9시 등교로 수면시간이 늘어난 학생이 많아 졌기 때문입니다. 지난 10일 광주시교육청이 초·중·고교 학생 2391명과 학부모 2960명(교사 1328명)을 대상으로 설문조사 결과 오전 8시 30분 이전 강제등교를 금지하는 ‘9시 등교제’ 실시로 학생의 80.5%가 1일 평균 수면 시간이 늘어났다고 응답하였습니다. 충분한 수면을 취하지 않는다면 뇌의 휴식이 줄어들어 면역기능 까지 손상을 입는다고 합니다. 또 수면을 취할때 몸의 신체기관은 휴식을 취하는데 이러한 과정에서 뇌는 필요한 정보를 기억하는 과정을 거칩니다. 그러면서 필요하지 않은 정보는 삭제 시키고 뇌가 판단을 하여 기억해야만 하는 정보를 장기적으로 저장해 줌으로 기억력이 향상 됩니다.둘째, 광주교육청의 설문조사 결과에 따르면 아침 식사 횟수는 주 5일 이상 아침 식사를 한다는 학생이 등교 시간 정책 이전(49.8%)보다 정책 이후 56.3%로 6.5% 늘었다.라고 응답하였습니다. 아침식사를 먹지 않는다면 몸의 기능이 제대로 발휘되지 않습니다. 특히 아침을 굶으면 대뇌 활동에 큰 지장을 받습니다. 또한 식사 횟수가 적을수록 심장병에 잘 걸린다는 조사 결과도 있습니다.이러한 근거로 저는 초중등학교 9시 등교 시행이 필요한 정책인가?라는 논제에 찬성합니다."""
# text4 ="""저는 찬성입니다.저는 개인적으로 수학을 좋아하고 즐기는데 수학은 계산보단 어떤 문제를 풀 방법을 생각하는 것에 더 가깝다고 생각합니다.실제로 유명한 수학자들도 계산을 못합니다. 저는 계산은 기계에게 맏기고 창의적인 수학적 방법풀이에 더 집중했으면 좋겠습니다.오일러라는 계산을 잘하는 굉장히 유명한 수학자가 있습니다. 저도 굉장히 존경하는 분인데, 그 분은 살아생전 수많은 논문을 내셨습니다. 그러나 오일러가 살던 시대에는 계산기가 없었기 때문에 오일러는 항상 계산이라는 단순 육체 노동을 해야 했습니다.그는 암산에도 능했지만 그 천재적인 능력을 단순 육체 노동인 계산을 하시느라 시간을 빼았겼습니다.  그 분은 소수들의 규칙을 찾는데 열중하셨는데  그 시대에는 계산기가 없어서 소수를 직접 찾아야 했습니다. 저는 오일러가 이 시대에 살았더라면 아름다운 소수 공식을 만들 수 있었지 않았을까 생각합니다.이 이야기를 하면서 제가 하고 싶은 얘긴 이와 같이 계산은 시간을 잡아먹는 단순 작업입니다. 여러분은 컴퓨터와 계산 배틀을 해서 이길 자신이 있으십까? 계산은 컴퓨터한테 시키고 단축된 시간에 더 연구해서 모르던 사실을 알아내면 좋겠습니다."""
# text5 ="""안녕하세요. 사드배치에 찬성하는 사람입니다.현재 북한은 우리의 군사적 주적이기 때문에 사드는 배치되어야 합니다.비용이 얼마나 들어가든 북한으로부터 우리나라 국민을 지킬 수 있으면 그만입니다.  1)저공 핵 타격은 북한으로써 불가능하다.혹자는 ‘북한이 저공 핵 타격을 하면 사드가 불필요하다’라고 합니다.그러나 저공 핵 타격을 할 만큼 북한이 핵을 가까이 배치한다면 이미 미국의 정찰기나 인공위성이 아마 추적을 한 상태일 것입니다.이미 미국은 북한의 두께 10cm물건마저도 탐지 가능한 정찰기와 인공위성을 띄어놓았기 때문에 북한은 핵을 그렇게 가까이 배치할 수가 없습니다.아무리 북한이 지하를 통해 핵을 배치한다 하더라도 그 준비과정이 미국 정찰기와 인공위성에 의해 추적이 될 것입니다.  2)한미동맹을 강화할 수 있다.혹자는 ‘사드 배치로 인해 중국이 경제적 재재가 이루어질 수 있지 않느냐’라고 합니다.중국이 우리나라 경제를 책임지는 건 사실입니다.그러나 문제는 중국의 경제를 미국이 책임진다는 것입니다.중국이 우리나라에 경제적 재재를 가한다면 미국이 중국에 경제적 재재를 가하면 그만입니다.중국과의 관계가 두터워지는 것보다 미국과의 관계가 두터워지는 것이 우리나라 입장으로 이득입니다."""
text_list = [text1]#, text2, text3, text4, text5]
# summary1 = get_summary(text, model1, tokenizer1)
# summary2 = get_summary(text1, model2, tokenizer2)
for text in text_list:
    summary3 = get_summary(text, model3, tokenizer2)
    summary4 = get_summary(text, model4, tokenizer2)
    summary5 = get_summary(text, model5, tokenizer2)
    summary6 = get_summary(text, model6, tokenizer2)
    summary7 = get_summary(text, model7, tokenizer2)



    # pp.pprint('summary1')
    # pp.pprint(summary1)
    # pp.pprint('summary2')
    # pp.pprint(summary2)
    print(f'\n\norigin text:{text}')
    pp.pprint('summary3')
    pp.pprint(summary3)
    pp.pprint('summary4')
    pp.pprint(summary4)
    pp.pprint('summary5')
    pp.pprint(summary5)
    pp.pprint('summary6')
    pp.pprint(summary6)
    pp.pprint('summary7')
    pp.pprint(summary7)



