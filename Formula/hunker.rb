class Hunker < Formula
  desc "Local GitHub pull-request and Git diff reviewer"
  homepage "https://github.com/sharno/hunker"

  on_macos do
    on_arm do
      url "https://github.com/sharno/hunker/releases/download/v0.2.0/hunker-v0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "69e0060278397da8fea8db98c5948a9c45f4b8bc71bf6980d29861e8dcbc4bbe"
    end
    on_intel do
      url "https://github.com/sharno/hunker/releases/download/v0.2.0/hunker-v0.2.0-x86_64-apple-darwin.tar.gz"
      sha256 "f949775fe9542bf073491aebee0db9a99f0a23d2e1c60b8f38b62167b69fecf8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/sharno/hunker/releases/download/v0.2.0/hunker-v0.2.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "9c9feec1a1c167978c3014f3c830538ec2e03c9a3338328ac9aa1b69f35141e7"
    end
    on_intel do
      url "https://github.com/sharno/hunker/releases/download/v0.2.0/hunker-v0.2.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "b78e0130de88947e5b976995552153224e4fd897a9a14d6974f242de2da608cc"
    end
  end

  def install
    bin.install "hunker"
    pkgshare.install "extension"
  end

  # Chrome remembers an unpacked extension by its resolved path, so keep a copy
  # outside the versioned Cellar that upgrades refresh in place.
  post_install_steps do
    remove "hunker/extension", base: :var, recursive: true
    copy "extension", "hunker/extension", source_base: :pkgshare, target_base: :var, recursive: true
  end

  def caveats
    <<~EOS
      Run `hunker` or `brew services start hunker`, then open
      http://127.0.0.1:5173. Private repositories use GITHUB_TOKEN or `gh auth`.

      To open GitHub links in Hunker, load its Chrome extension: turn on
      Developer mode in chrome://extensions, choose Load unpacked, and pick
        #{var}/hunker/extension
    EOS
  end

  service do
    run opt_bin/"hunker"
    keep_alive true
    environment_variables PATH: std_service_path_env
    log_path var/"log/hunker.log"
    error_log_path var/"log/hunker.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/hunker --version")
    assert_path_exists pkgshare/"extension/manifest.json"

    port = free_port
    pid = spawn({ "HUNKER_PORT" => port.to_s, "HUNKER_CONFIG_FILE" => (testpath/"settings.json").to_s },
                bin/"hunker")
    begin
      sleep 2
      assert_match "<title>Hunker", shell_output("curl -s http://127.0.0.1:#{port}/")
      assert_match '"application":"hunker"', shell_output("curl -s http://127.0.0.1:#{port}/api/about")
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
