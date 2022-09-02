//
//  LawAndGuideManager.swift
//  Discussion-Korea-Backend
//
//  Created by 이청수 on 2022/09/02.
//

import Foundation

fileprivate typealias Map = [String: Any]

final class LawManager {

    static let shared = LawManager()

    private init() {}

    func observe() {
        let reference = ReferenceManager.reference
        reference.observeSingleEvent(of: .value) { [unowned self] snapshot in
            if !snapshot.hasChild("laws") {
                reference.child("laws").setValue(self.initialLaws())
            }
        }
    }

    private func initialLaws() -> Map {
        var laws = Map()
        laws["lastUpdated"] = "2022-06-18"
        var lawItems = [Map]()
        lawItems.append({
            var map = Map()
            map["topic"] = "방구석대한민국 이용 철학에 대하여"
            map["contents"] = """
            ① 방구석대한민국은 성별, 학력, 연령, 지역, 종교 등 모든 영역에 있어서 이용에 차별을 받지 아니한다.
            ② 그에 따라 플랫폼 내에서 상대방의 인적사항을 묻는 행위는 허용하지 않는다. 단, 자발적으로 말하는 것은 예외로 한다.
            ③ 자유를 존중하되 규칙을 준수한다.
            ④ 근거 없는 주장이나 가짜 뉴스를 지양하며 논리적 말하기를 추구한다.
            ⑤ 방구석대한민국은 시민 참여 정치 플랫폼으로서, 특정정당의 입장만을 대변하거나, 주장을 관철하지 않는다. 단, 특정 정당을 지지하거나 비판하는 것은 가능하다.
            """
            return map
        }())
        lawItems.append({
            var map = Map()
            map["topic"] = "방구석대한민국 이용 수칙에 대하여"
            map["contents"] = """
            ① 텍스트가 중점인 플랫폼이므로 올바른 맞춤법이나 띄어쓰기를 지향한다.
            ② 불필요한 신조어 사용을 지양하고, 올바른 한글 사용을 지향한다.
            """
            return map
        }())
        lawItems.append({
            var map = Map()
            map["topic"] = "자유토론 지향에 관하여"
            map["contents"] = """
            ① 본 플랫폼은 자유로운 토론문화를 지향하며, 형식에 얽매이지 않는다.
            """
            return map
        }())
        lawItems.append({
            var map = Map()
            map["topic"] = "소수의 의견 보호에 관하여"
            map["contents"] = """
            ① 본 플랫폼은 소수의 의견을 존중함을 원칙으로 한다.
            ② 개진하는 의견이 비록 소수일지라도, 다수 여론에 의해 압박 받지 아니할 권리가 있으며, 타인의 의견을 제약하지 않는 선에서 자유롭게 발언할 수 있다.
            ③ 소수의 의견을 존중하되, 소수라고 해서 특혜를 받거나 주지 아니한다.
            """
            return map
        }())
        lawItems.append({
            var map = Map()
            map["topic"] = "토론 상대방에 관하여"
            map["contents"] = """
            ① 토론의 본질적인 목적은 상대 패널을 설득하는 것이 아닌, 청중을 설득하는 것이므로, 토론 중 상대 패널에 대한 예의를 갖추어야 한다.
            ② 상대 패널에 대한 예의에 어긋나는 사례로는 조롱성 표현, 비방성 표현, 상대의 발언을 가로막는 행위, 등이 있다.
            ③ 자유로운 말하기의 권리를 얻었으므로 그에 대한 의무를 책임지고 그러지 못했을 경우 처벌을 겸허히 받아들인다.
            """
            return map
        }())
        lawItems.append({
            var map = Map()
            map["topic"] = "발언권에 대하여"
            map["contents"] = """
            ① 토론 참가자들의 발언권 보장은 반드시 지켜져야 한다.
            ② 토론 참가자들은 매 발언 시, 각각 1개의 주장과 논지를 펴는 것을 권고한다.
            ③ 각 토론 참가자는 상대에게 던진 질문에 대하여, 상대방이 모두 답변(소명)할 수 있도록 발언권을 존중해야 한다.
            """
            return map
        }())
        lawItems.append({
            var map = Map()
            map["topic"] = "주장에 대하여"
            map["contents"] = """
            ① 토론 참가자는 주장(입론)시, 모호한 표현을 최대한 줄이고, 명확하게 주장해야 한다.
            ② 주장(입론)은 양립 가능 한 표현이 아닌, 대립 가능 한 표현이어야 한다.
            """
            return map
        }())
        laws["items"] = lawItems
        lawItems.append({
            var map = Map()
            map["topic"] = "근거 제시에 대하여"
            map["contents"] = """
            ① 주장을 뒷받침할 근거를 제시할 때에는 출처를 반드시 밝힌다.
            ② 근거를 제시할 때는 객관적이고 정확한 수치를 제시하도록 한다.
            ③ 제시한 근거 중 도표나 그래프 등의 통계 자료가 있을 때에는, 범주를 명확히 하여 수치에 의한 왜곡이 일어나지 않도록 해야 한다.
            """
            return map
        }())
        lawItems.append({
            var map = Map()
            map["topic"] = "토론의 결과에 대하여"
            map["contents"] = """
            ① 본 플랫폼의 토론 결과물은 구성원들의 투표로 결정된다.
            ② 결정된 결과에는 깨끗이 승복한다.
            """
            return map
        }())
        lawItems.append({
            var map = Map()
            map["topic"] = "분쟁 조정에 대하여"
            map["contents"] =
            """
            ① 본 플랫폼은 상호 존중에 입각하여 토론함을 원칙으로 한다.
            ② 필요 이상으로 논쟁이 과열되어, 분쟁이 발생한 경우, 1차적으로 함께 토론하던 다른 위원들이 중재한다.
            ③ 1차적 중재가 통하지 않을 시, 당사자 또는 제3자는 분쟁조정위원장에게 중재를 요청할 수 있다.
            ④ 제 3항에서 중재요청을 받은 분쟁조정위원장은 토론에 개입하여 분쟁을 중재할 수 있다.
            ⑤ 제 4항에서 중재를 진행한 분쟁조정위원장은 분쟁조정요청자에게 다음과 같이 결과를 통보하여야 한다.
            1) 분쟁조정완료(토론 진행 중 해결 시)
            2) 공식적인 경고
            3) 강제 퇴장 (경고 2회 초과시)
            """
            return map
        }())
        laws["items"] = lawItems
        return laws
    }

}

final class GuideManager {

    static let shared = GuideManager()

    private init() {}

    func observe() {
        let reference = ReferenceManager.reference
        reference.observeSingleEvent(of: .value) { snapshot in
            if !snapshot.hasChild("guides") {
                reference.child("guides").setValue(self.initialGuides())
            }
        }
    }

    private func initialGuides() -> [Map] {
        return [
            {
                var map = Map()
                map["title"] = "방구석 대한민국은?"
                map["content"] = "방구석 대한민국은 직접민주주의 시민참여 정치플랫폼으로서, 일반시민들의 의견을 모아 구성된 메타버스 가상정부 입니다."
                return map
            }(),
            {
                var map = Map()
                map["title"] = "방구석 대한민국의 슬로건"
                map["content"] = "시민으로부터 나온 권력을 다시 시민에게로"
                return map
            }(),
            {
                var map = Map()
                map["title"] = "방구석 대한민국의 룰"
                map["content"] = "방구석 대한민국 플랫폼내에서는 자유로운 의사표명 및 토론을 하실 수 있습니다. 단, 방구석 헌법에 저촉되는 행위시 이용에 제약을 받으실 수 있습니다."
                return map
            }()
        ]
    }

}
