module Achoo
  VERSION = begin
    v = '0.5.1'
    origin_master_commits = `git rev-list origin/master`.split("\n")
    v << '.' << origin_master_commits.length.to_s
  end
end