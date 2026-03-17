import pytest

from config.player_mapping import build_id_map, mlbam_to_fg, fg_to_mlbam


@pytest.fixture(scope="module")
def id_map():
    return build_id_map()


def test_id_map_loads(id_map):
    assert len(id_map) > 1000
    assert "key_mlbam" in id_map.columns
    assert "key_fangraphs" in id_map.columns


def test_id_map_no_nulls(id_map):
    assert id_map["key_mlbam"].notna().all()
    assert id_map["key_fangraphs"].notna().all()


def test_aaron_judge_mlbam_to_fg():
    result = mlbam_to_fg([592450])
    assert 592450 in result
    assert result[592450] == 15640


def test_aaron_judge_fg_to_mlbam():
    result = fg_to_mlbam([15640])
    assert 15640 in result
    assert result[15640] == 592450


def test_batch_lookup():
    ids = [592450, 545361]  # Judge, Trout
    result = mlbam_to_fg(ids)
    assert len(result) == 2
    assert 592450 in result
    assert 545361 in result
