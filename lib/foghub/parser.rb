class CommitParser
  attr_accessor :aliases

  def initialize(commit)
    @raw_commit = commit
  end

  def cases
    @cases ||= parse_cases
  end

  def review?
    @review ||= parse_review
  end

  def reviewer_ids
    ids = []

    # Unsure how to return from #each to #map
    # thus not using #map
    reviewers.each do |reviewer_alias|
      @aliases.each do |id, aliases|
        ids << id if aliases.index(reviewer_alias)
      end
    end

    ids
  end


  def reviewers
    @reviewer ||= parse_reviewers
  end

  private
  def parse_cases
    # #flatten because it returns Inception arrays (arrays inside arrays)
    return [] if @raw_commit =~ /pull request/
    @raw_commit.scan(/#(\d+)/).flatten.map(&:to_i)
  end

  def parse_review
    @raw_commit.match(/#review/)
  end

  def parse_reviewers
    # INCEPTION
    @raw_commit.scan(/@(\w+)/).flatten.map(&:downcase)
  end
end
