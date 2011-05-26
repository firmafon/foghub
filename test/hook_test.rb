require 'test_helper'
require 'foghub.rb'
require 'json'

class CommitMessage < FogTest
  def app
    @app ||= Foghub.new
  end

  def github_data(message)
    {
      :before => "5aef35982fb2d34e9d9d4502f6ede1072793222d",
      :repository => {
        :url => "http://github.com/firmafon/foghub",
        :name => "github",
        :description => "Foghub associates Git commits with Fogbugz cases and code reviews.",
        :watchers => 2,
        :forks => 1,
        :private => 0,
        :owner => {
          :email => "teknik@firmafon.dk",
          :name => "firmafon"
        }
      },
      :commits => [
        {
          :id => "41a212ee83ca127e3c8cf465891ab7216a705f59",
          :url => "http://github.com/firmafon/foghub/commit/41a212ee83ca127e3c8cf465891ab7216a705f59",
          :author => {
            :email => "sirup@sirupsen.com",
            :name => "Sirupsen"
          },
          :message => message,
          :timestamp => "2008-02-15T14:57:17-08:00",
          :added => ["ohai.rb"]
        },
      ],
      :after => "de8251ff97ee194a289832576287d6f8ad74e3d0",
      :ref => "refs/heads/master"
    }.to_json
  end

  test 'when commit has review tag and >= 1 reviwers, it should create a code review for the right person' do
    app.instance = mock()
    app.config = {
      :aliases => {
        2 => ["sirupsen", "sirup"]
      }
    }

    app.fogbugz.expects(:command).with(:new, {:sPersonAssignedTo => 2, :sCategory => 'Code Review', :sEvent => 'commit needs #review by @sirupsen http://github.com/firmafon/foghub/commit/41a212ee83ca127e3c8cf465891ab7216a705f59'})

    post '/commit', :payload => github_data('commit needs #review by @sirupsen')
  end

  test 'when commit has review tag, reviewer and a case' do
    app.instance = mock()
    app.config = {
      :aliases => {
        2 => ["sirupsen", "sirup"]
      }
    }
    
    app.fogbugz.expects(:command).with(:new, {:sPersonAssignedTo => 2, :sCategory => 'Code Review', :sEvent => 'commit for #87 needs #review by @sirupsen http://github.com/firmafon/foghub/commit/41a212ee83ca127e3c8cf465891ab7216a705f59'})
    app.fogbugz.expects(:command).with(:edit, {:ixBug => 87, :sEvent => 'commit for #87 needs #review by @sirupsen http://github.com/firmafon/foghub/commit/41a212ee83ca127e3c8cf465891ab7216a705f59'})

    post '/commit', :payload => github_data('commit for #87 needs #review by @sirupsen')
  end

  test 'when requesting with no payload it should raise an exception' do
    assert_raises StandardError do
      post '/commit', :useless => "data"
    end
  end

  test 'when commit has no review tag it but has fogbugz case it should simply associate with the fogbugz case' do
    commit = 'commit with a case #18'

    app.instance = mock()
    app.fogbugz.expects(:command).with(:edit, {:ixBug => 18, :sEvent => 'commit with a case #18 http://github.com/firmafon/foghub/commit/41a212ee83ca127e3c8cf465891ab7216a705f59'})

    post '/commit', :payload => github_data(commit)
  end

  test 'when commit mentions a user and a case it should assign the case to the mentioned user' do
    commit = 'commit with a case #18 assign back to @sirupsen'

    app.instance = mock()
    app.config = {
      :aliases => {
        2 => ["sirupsen", "sirup"]
      }
    }

    app.fogbugz.expects(:command).with(:edit, {:ixBug => 18, :sEvent => 'commit with a case #18 assign back to @sirupsen http://github.com/firmafon/foghub/commit/41a212ee83ca127e3c8cf465891ab7216a705f59'})

    post '/commit', :payload => github_data(commit)
  end
end
