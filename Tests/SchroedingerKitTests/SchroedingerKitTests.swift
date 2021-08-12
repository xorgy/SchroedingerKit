import XCTest
@testable import SchroedingerKit

final class SchroedingerKitTests: XCTestCase {
    func integer_keys_invert() {
        var baar = FullTextInvertIndex<Int>();
        baar.insert(k: 69, index_string: "boof");
        baar.insert(k: 420, index_string: "foob");

        var fooo = FullTextInvertIndex<Int>();
        fooo.insert(k: 420, index_string: "foob");
        fooo.insert(k: 69, index_string: "boof");

        XCTAssertEqual(baar.index, fooo.index);
        XCTAssertEqual(baar.query(query: "oof"), fooo.query(query: "oof"));
    }

    func str_keys_invert() {
        var quux = FullTextInvertIndex<String>();
        quux.insert(k: "pleased", index_string: "boof");
        quux.insert(k: "blazed", index_string: "foob");

        var baaz = FullTextInvertIndex<String>();
        baaz.insert(k: "blazed", index_string: "foob");
        baaz.insert(k: "pleased", index_string: "boof");

        XCTAssertEqual(quux.index, baaz.index);
        XCTAssertEqual(quux.query(query: "oof"), baaz.query(query: "oof"));
    }

    func invert_vs_merge_from() {
        var baar = FullTextInvertIndex<Int>();
        baar.insert(k: 69, index_string: "boof");
        baar.insert(k: 420, index_string: "foob");

        let fooo = baar.toMerge();

        XCTAssertEqual(baar.query(query: "oof"), fooo.query(query: "oof"));
    }


    func test_start_end_sensitive() {
        var baar = FullTextInvertIndex<String>(depth: 2);

        baar.insertBounded(k: "blazed", index_string: "Adiaeresis");
        baar.insertBounded(k: "crazed", index_string: "Aacute");
        baar.insertBounded(k: "pleased", index_string: "A");

        XCTAssertEqual(baar.queryBounded(query: "A")[0], "pleased");
        XCTAssertEqual(baar.queryBounded(query: "Ate")[0], "crazed");
        XCTAssertEqual(baar.queryBounded(query: "Ais")[0], "blazed");
        XCTAssertEqual(baar.queryBounded(query: "Ad")[0], "blazed");
    }

    func test_multibyte() {
        var baar = FullTextInvertIndex<String>(depth: 2);

        baar.insertBounded(k: "chickity", index_string: "中ity中國，這中華的雞");
        baar.insertBounded(k: "kurosawa", index_string: "like 黒沢 I make mad films");
        baar.insertBounded(k: "sushi", index_string: "I like the 寿司 'cause it's never touched a frying pan");

        XCTAssertEqual(baar.queryBounded(query: "寿司")[0], "sushi");
        XCTAssertEqual(baar.queryBounded(query: "黒沢")[0], "kurosawa");
        XCTAssertEqual(baar.queryBounded(query: "中華的雞")[0], "chickity");
    }

    func test_sub_grapheme_match() {
        var baar = FullTextInvertIndex<String>();

        baar.insertBounded(k: "제11조 ①", index_string: "제11조 ① 모든 국민은 법 앞에 평등하다. 누구든지 성별·종교 또는 사회적 신분에 의하여 정치적·경제적·사회적·문화적 생활의 모든 영역에 있어서 차별을 받지 아니한다.");
        baar.insertBounded(k: "-e", index_string: "법률에");
        baar.insertBounded(k: "-i", index_string: "법률이");

        XCTAssertEqual(baar.queryBounded(query: "모든 국민은 법 앞에 평등하ᄃ")[0], "제11조 ①");
        XCTAssertEqual(baar.queryBounded(query: "법률이")[0], "-i");
        XCTAssertEqual(baar.queryBounded(query: "법률에")[0], "-e");
        XCTAssertEqual(baar.queryBounded(query: "법률이")[1], "-e");
    }

    func integer_keys_merge() {
        var baar = FullTextMergeIndex<Int>();
        baar.insert(k: 69, index_string: "boof");
        baar.insert(k: 420, index_string: "foob");

        var fooo = FullTextMergeIndex<Int>();
        fooo.insert(k: 420, index_string: "foob");
        fooo.insert(k: 69, index_string: "boof");

        XCTAssertEqual(baar.index, fooo.index);
        XCTAssertEqual(baar.query(query: "oof"), fooo.query(query: "oof"));
    }

    func str_keys_merge() {
        var quux = FullTextMergeIndex<String>();
        quux.insert(k: "pleased", index_string: "boof");
        quux.insert(k: "blazed", index_string: "foob");

        var baaz = FullTextMergeIndex<String>();
        baaz.insert(k: "blazed", index_string: "foob");
        baaz.insert(k: "pleased", index_string: "boof");

        XCTAssertEqual(quux.index, baaz.index);
        XCTAssertEqual(quux.query(query: "oof"), baaz.query(query: "oof"));
    }

    func invert_vs_merge() {
        var baar = FullTextInvertIndex<Int>();
        baar.insert(k: 69, index_string: "boof");
        baar.insert(k: 420, index_string: "foob");

        var fooo = FullTextMergeIndex<Int>();
        fooo.insert(k: 420, index_string: "foob");
        fooo.insert(k: 69, index_string: "boof");

        XCTAssertEqual(baar.query(query: "oof"), fooo.query(query: "oof"));
    }

    func merge_vs_invert_from() {
        var baar = FullTextMergeIndex<Int>();
        baar.insert(k: 69, index_string: "boof");
        baar.insert(k: 420, index_string: "foob");

        let fooo = baar.toInvert();

        XCTAssertEqual(baar.query(query: "oof"), fooo.query(query: "oof"));
    }

    static var allTests = [
      ("integer_keys_invert", integer_keys_invert),
      ("str_keys_invert", str_keys_invert),
      ("invert_vs_merge_from", invert_vs_merge_from),
      ("test_start_end_sensitive", test_start_end_sensitive),
      ("test_multibyte", test_multibyte),
      ("test_sub_grapheme_match", test_sub_grapheme_match),
      ("integer_keys_merge", integer_keys_merge),
      ("str_keys_merge", str_keys_merge),
      ("invert_vs_merge", invert_vs_merge),
      ("merge_vs_invert_from", merge_vs_invert_from),
    ]
}
