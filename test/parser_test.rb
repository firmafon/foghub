require 'test_helper'
require 'foghub/parser'

class Parser < FogTest
  test "test parsing commit with one case should return right case" do
    commit = "Added awesome feature, fixes #42"
    commit = CommitParser.new(commit)

    assert_equal [42], commit.cases
  end

  test "test parsing commit with more than one case should return all cases" do
    commit = "Added awesome feature, fixes #42 and #48"
    commit = CommitParser.new(commit)

    assert_equal [42, 48], commit.cases
  end

  test "test parsing commit with review should find review" do
    commit = "Added awesome feature, fixes #42 and #48 someone should #review"
    commit = CommitParser.new(commit)

    assert commit.review?
  end

  test "test parsing commit with no review should not find review" do
    commit = "Added awesome feature, fixes #42 and #48"
    commit = CommitParser.new(commit)

    assert_nil commit.review?
  end

  test "test parsing commit with a reviewer should find reviewer" do
    commit = "Added awesome feature, fixes #42 and #48 #review @sirupsen"
    commit = CommitParser.new(commit)

    assert_equal ['sirupsen'], commit.reviewers
  end

  test "test parsing commit with multiple reviews should find all reviewers" do
    commit = "Added awesome feature, fixes #42 and #48 #review @sirupsen @mkyed"
    commit = CommitParser.new(commit)

    assert_equal ['sirupsen', 'mkyed'], commit.reviewers
  end

  test "reviewers should be lowercased" do
    commit = "Added awesome feature, fixes #42 and #48 #review @SiRuPSEN @mKyeD"
    commit = CommitParser.new(commit)

    assert_equal ['sirupsen', 'mkyed'], commit.reviewers
  end

  test "test parsing commit should not catch at as empty reviewer" do
    commit = "Added awesome feature @ admin2, fixes #42 and #48 #review @sirupsen @mkyed"
    commit = CommitParser.new(commit)

    assert_equal 2, ['sirupsen', 'mkyed'].count
  end

  test 'associate right aliases with right IDs' do
    commit = "Added awesome feature @ admin2, fixes #42 and #48 #review @sirupsen @mkyed"
    commit = CommitParser.new(commit)

    commit.aliases = {
        2 => ["sirupsen", "sirup"],
        4 => ["mkyed", "michael", "kyed"],
        8 => ["harey", "vangberg", "ichverstehe"]
    }

    ids = commit.reviewer_ids

    assert_equal [2, 4], ids
  end

  test 'parsing commits for pull requests shouldn\'t give cases' do
    commit = "Merge pull request #15 from"
    commit = CommitParser.new(commit)

    assert_empty commit.cases
  end

  test 'parsing commits with no cases should yield an empty array' do
    commit = "fix"
    commit = CommitParser.new(commit)

    assert_empty commit.cases
  end
end
