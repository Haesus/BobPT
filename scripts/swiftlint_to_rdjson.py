#!/usr/bin/env python3
import json
import os
import sys


RULE_MESSAGES = {
    "anonymous_argument_in_multiline_closure": "여러 줄 클로저에서는 익명 인자보다 명시적인 인자 이름을 사용하면 흐름을 읽기 쉽습니다.",
    "array_init": "`map` 또는 `compactMap` 결과를 `Array(...)`로 감싸기보다 직접 사용하는 편이 더 명확합니다.",
    "attributes": "Swift attribute 위치나 줄바꿈 형식이 규칙과 맞지 않습니다.",
    "block_based_kvo": "문자열 기반 KVO보다 block 기반 KVO를 사용하는 편이 안전합니다.",
    "class_delegate_protocol": "delegate 프로토콜은 클래스 전용으로 제한해 순환 참조 관리를 명확히 해 주세요.",
    "closing_brace": "닫는 중괄호 위치가 Swift 스타일과 맞지 않습니다.",
    "closure_body_length": "클로저 본문이 길어졌습니다. 역할을 나누거나 별도 함수로 분리할 수 있는지 확인해 주세요.",
    "closure_end_indentation": "클로저의 닫는 위치 들여쓰기가 시작 위치와 맞지 않습니다.",
    "closure_parameter_position": "클로저 파라미터 위치가 규칙과 맞지 않습니다.",
    "closure_spacing": "클로저 선언 주변 공백을 정리해 주세요.",
    "colon": "콜론 앞뒤 공백이 Swift 스타일과 맞지 않습니다.",
    "comma": "쉼표 앞뒤 공백이 Swift 스타일과 맞지 않습니다.",
    "comment_spacing": "주석의 `//` 뒤에는 공백을 하나 두는 편이 읽기 좋습니다.",
    "compiler_protocol_init": "컴파일러가 직접 호출하는 프로토콜 초기화는 직접 사용하지 않는 편이 안전합니다.",
    "contains_over_filter_count": "`filter(...).count`보다 `contains`를 사용하면 의도가 더 명확하고 효율적입니다.",
    "contains_over_filter_is_empty": "`filter(...).isEmpty`보다 `contains` 또는 부정 조건을 사용하면 의도가 더 명확합니다.",
    "contains_over_first_not_nil": "`first(where:) != nil`보다 `contains`를 사용하면 의도가 더 명확합니다.",
    "control_statement": "`if`, `for`, `while` 같은 제어문 조건에는 불필요한 괄호를 제거해 주세요.",
    "cyclomatic_complexity": "분기 수가 많아졌습니다. 조건을 나누거나 책임을 분리할 수 있는지 확인해 주세요.",
    "deployment_target": "현재 배포 타겟에서 사용할 수 없는 API일 수 있습니다.",
    "discouraged_direct_init": "직접 초기화보다 권장되는 생성 API를 사용해 주세요.",
    "duplicate_enum_cases": "enum case가 중복되어 있습니다.",
    "duplicate_imports": "중복 import를 제거해 주세요.",
    "duplicated_key_in_dictionary_literal": "Dictionary literal에 중복 key가 있습니다.",
    "dynamic_inline": "`dynamic`과 `@inline(__always)` 조합은 피하는 편이 안전합니다.",
    "empty_collection_literal": "빈 배열/딕셔너리 비교보다 `isEmpty`를 사용해 주세요.",
    "empty_count": "`count == 0` 또는 `count > 0`보다 `isEmpty`를 사용하면 의도가 더 명확합니다.",
    "empty_enum_arguments": "사용하지 않는 enum associated value 이름은 제거해 주세요.",
    "empty_parameters": "빈 클로저 파라미터 `()`는 생략할 수 있습니다.",
    "empty_parentheses_with_trailing_closure": "trailing closure를 사용할 때 불필요한 빈 괄호를 제거해 주세요.",
    "explicit_init": "불필요한 `.init` 호출은 타입 추론을 해치므로 생략하는 편이 좋습니다.",
    "fallthrough": "`fallthrough` 사용은 의도를 흐릴 수 있어 필요한 경우에만 사용해 주세요.",
    "fatal_error_message": "`fatalError`에는 디버깅 가능한 메시지를 함께 남겨 주세요.",
    "file_length": "파일이 길어졌습니다. 책임을 나누거나 타입을 분리할 수 있는지 확인해 주세요.",
    "first_where": "`filter(...).first`보다 `first(where:)`를 사용하면 더 효율적입니다.",
    "for_where": "`for` 내부의 단순 `if` 조건은 `for where`로 표현할 수 있습니다.",
    "force_cast": "강제 캐스팅은 런타임 크래시 위험이 있습니다. `as?` 또는 안전한 분기 처리를 검토해 주세요.",
    "force_try": "`try!`는 런타임 크래시 위험이 있습니다. `do-catch` 또는 `try?`를 검토해 주세요.",
    "force_unwrapping": "강제 언래핑은 런타임 크래시 위험이 있습니다. `guard let`, `if let`, 기본값 처리 등을 검토해 주세요.",
    "function_body_length": "함수 본문이 길어졌습니다. 역할을 나누거나 작은 함수로 분리할 수 있는지 확인해 주세요.",
    "function_parameter_count": "함수 파라미터가 많습니다. 모델이나 설정 타입으로 묶을 수 있는지 확인해 주세요.",
    "identifier_name": "식별자 이름이 규칙과 맞지 않습니다. 의미가 드러나는 이름인지 확인해 주세요.",
    "implicit_getter": "읽기 전용 computed property에서는 불필요한 `get`을 생략할 수 있습니다.",
    "implicitly_unwrapped_optional": "암시적 언래핑 옵셔널은 예기치 않은 크래시를 만들 수 있습니다. 일반 Optional 사용을 검토해 주세요.",
    "is_disjoint": "교집합 여부 확인에는 `isDisjoint(with:)`를 사용하면 더 명확합니다.",
    "large_tuple": "Tuple 요소가 많습니다. 의미 있는 타입으로 분리하는 편이 유지보수에 좋습니다.",
    "leading_whitespace": "줄 앞쪽의 불필요한 공백을 제거해 주세요.",
    "legacy_cggeometry_functions": "레거시 CoreGraphics 함수보다 Swift property/API를 사용해 주세요.",
    "legacy_constant": "레거시 상수보다 Swift 타입 프로퍼티를 사용해 주세요.",
    "legacy_constructor": "레거시 생성자보다 Swift initializer를 사용해 주세요.",
    "legacy_hashing": "`hashValue`를 직접 사용하기보다 `hash(into:)`를 구현해 주세요.",
    "legacy_nsgeometry_functions": "레거시 NSGeometry 함수보다 Swift property/API를 사용해 주세요.",
    "line_length": "한 줄이 길어졌습니다. 줄바꿈으로 가독성을 높여 주세요.",
    "mark": "`// MARK: - 제목` 형식처럼 MARK 주석 형식을 맞춰 주세요.",
    "modifier_order": "접근 제어자와 modifier 순서를 Swift 스타일에 맞게 정리해 주세요.",
    "multiple_closures_with_trailing_closure": "여러 클로저 인자가 있을 때 trailing closure 사용은 호출부를 헷갈리게 할 수 있습니다.",
    "nesting": "중첩이 깊어졌습니다. 타입이나 로직을 분리할 수 있는지 확인해 주세요.",
    "notification_center_detachment": "NotificationCenter observer 해제가 필요한 흐름인지 확인해 주세요.",
    "opening_brace": "여는 중괄호 앞 공백과 위치를 Swift 스타일에 맞게 정리해 주세요.",
    "operator_whitespace": "연산자 앞뒤 공백을 정리해 주세요.",
    "orphaned_doc_comment": "문서 주석이 선언에 연결되지 않았습니다.",
    "private_over_fileprivate": "`fileprivate`보다 더 좁은 `private`을 사용할 수 있는지 확인해 주세요.",
    "private_unit_test": "private 선언은 테스트에서 접근하기 어렵습니다. 필요한 접근 수준인지 확인해 주세요.",
    "protocol_property_accessors_order": "프로토콜 프로퍼티 접근자 순서는 `get set` 형태로 맞춰 주세요.",
    "redundant_discardable_let": "결과를 버릴 때 `let _ =`보다 `_ =`를 사용해 주세요.",
    "redundant_objc_attribute": "불필요한 `@objc` attribute를 제거해 주세요.",
    "redundant_optional_initialization": "Optional은 기본값이 `nil`이므로 불필요한 `= nil`을 제거할 수 있습니다.",
    "redundant_string_enum_value": "문자열 enum case 값이 case 이름과 같다면 생략할 수 있습니다.",
    "redundant_void_return": "불필요한 `-> Void` 반환 표기를 제거할 수 있습니다.",
    "return_arrow_whitespace": "반환 화살표 `->` 앞뒤 공백을 정리해 주세요.",
    "shorthand_operator": "`foo = foo + bar`보다 `foo += bar`처럼 축약 연산자를 사용할 수 있습니다.",
    "sorted_first_last": "정렬 후 첫/마지막 값을 꺼내기보다 `min()` 또는 `max()`를 검토해 주세요.",
    "statement_position": "`else`, `catch` 위치를 Swift 스타일에 맞게 정리해 주세요.",
    "superfluous_disable_command": "필요 없는 SwiftLint disable 주석을 제거해 주세요.",
    "switch_case_alignment": "`case` 들여쓰기를 `switch` 블록 기준에 맞춰 정리해 주세요.",
    "syntactic_sugar": "`Array<T>`보다 `[T]`처럼 Swift 문법 설탕을 사용하는 편이 좋습니다.",
    "todo": "TODO/FIXME가 남아 있습니다. 이번 PR에서 해결하거나 별도 이슈로 관리해 주세요.",
    "trailing_comma": "컬렉션 literal의 마지막 쉼표 사용 여부를 규칙에 맞춰 주세요.",
    "trailing_newline": "파일 마지막에는 줄바꿈을 하나 남겨 주세요.",
    "trailing_semicolon": "Swift에서는 줄 끝 세미콜론이 불필요합니다.",
    "trailing_whitespace": "줄 끝의 불필요한 공백을 제거해 주세요.",
    "type_body_length": "타입 본문이 길어졌습니다. 책임을 나누거나 extension으로 분리할 수 있는지 확인해 주세요.",
    "type_name": "타입 이름이 규칙과 맞지 않습니다. 의미가 드러나는 이름인지 확인해 주세요.",
    "unneeded_break_in_switch": "`switch` case 마지막의 불필요한 `break`를 제거할 수 있습니다.",
    "unneeded_override": "동작을 바꾸지 않는 override는 제거할 수 있습니다.",
    "unneeded_synthesized_initializer": "Swift가 자동 생성하는 initializer는 직접 선언하지 않아도 됩니다.",
    "unowned_variable_capture": "`unowned` 캡처는 해제 이후 접근 시 크래시가 납니다. `weak` 사용을 검토해 주세요.",
    "unused_closure_parameter": "사용하지 않는 클로저 파라미터는 `_`로 표시해 주세요.",
    "unused_control_flow_label": "사용하지 않는 control flow label을 제거해 주세요.",
    "unused_enumerated": "index가 필요 없다면 `.enumerated()`를 제거해 주세요.",
    "unused_optional_binding": "값을 사용하지 않는 optional binding은 boolean 조건으로 바꿀 수 있습니다.",
    "valid_ibinspectable": "`@IBInspectable`로 지원되는 타입인지 확인해 주세요.",
    "vertical_parameter_alignment": "여러 줄 파라미터의 세로 정렬을 맞춰 주세요.",
    "vertical_whitespace": "불필요하게 연속된 빈 줄을 정리해 주세요.",
    "void_return": "`Void` 반환 표기를 일관된 형태로 정리해 주세요.",
    "weak_delegate": "delegate는 순환 참조를 막기 위해 일반적으로 `weak`으로 선언합니다.",
}


def load_violations(path):
    with open(path, "r", encoding="utf-8") as file:
        content = file.read().strip()

    if not content:
        return []

    data = json.loads(content)
    if not isinstance(data, list):
        raise ValueError("SwiftLint JSON report must be a list.")

    return data


def positive_int(value, default):
    try:
        return max(1, int(value))
    except (TypeError, ValueError):
        return default


def relative_path(path, root):
    if not path:
        return path

    absolute_path = os.path.abspath(path)
    try:
        return os.path.relpath(absolute_path, root)
    except ValueError:
        return path


def translated_message(violation):
    rule_id = violation.get("rule_id", "unknown_rule")
    original_reason = violation.get("reason", "No SwiftLint reason provided.")
    korean_message = RULE_MESSAGES.get(rule_id)

    if korean_message:
        return f"{korean_message}\n\nSwiftLint 규칙: `{rule_id}`\n원문: {original_reason}"

    return f"SwiftLint 규칙 위반입니다. `{rule_id}` 규칙을 확인해 주세요.\n\n원문: {original_reason}"


def severity(value):
    normalized = str(value or "warning").lower()
    if normalized == "error":
        return "ERROR"
    if normalized == "warning":
        return "WARNING"
    return "INFO"


def rule_url(rule_id):
    anchor = str(rule_id).replace("_", "-")
    return f"https://realm.github.io/SwiftLint/rule-directory.html#{anchor}"


def to_diagnostic(violation, root):
    line = positive_int(violation.get("line"), 1)
    column = positive_int(violation.get("character"), 1)
    rule_id = violation.get("rule_id", "unknown_rule")

    return {
        "message": translated_message(violation),
        "location": {
            "path": relative_path(violation.get("file", ""), root),
            "range": {
                "start": {
                    "line": line,
                    "column": column,
                }
            },
        },
        "severity": severity(violation.get("severity")),
        "code": {
            "value": rule_id,
            "url": rule_url(rule_id),
        },
    }


def main():
    if len(sys.argv) != 3:
        print("Usage: swiftlint_to_rdjson.py <swiftlint-json> <rdjson-output>", file=sys.stderr)
        return 2

    input_path = sys.argv[1]
    output_path = sys.argv[2]
    root = os.getcwd()

    violations = load_violations(input_path)
    rdjson = {
        "source": {
            "name": "SwiftLint 코드 규칙 검사",
            "url": "https://github.com/realm/SwiftLint",
        },
        "diagnostics": [to_diagnostic(violation, root) for violation in violations],
    }

    with open(output_path, "w", encoding="utf-8") as file:
        json.dump(rdjson, file, ensure_ascii=False, indent=2)
        file.write("\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
