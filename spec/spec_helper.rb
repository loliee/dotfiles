require 'serverspec'
require 'tempfile'

set :backend, :exec
set :path, '~/.homebrew/bin:/usr/local/go/bin/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH'
set :request_pty, true
