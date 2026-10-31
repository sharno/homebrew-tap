class Hunker < Formula
  desc "Local GitHub pull-request and Git diff reviewer"
  homepage "https://github.com/sharno/hunker"

  on_macos do
    on_arm do
      url "https://github.com/sharno/hunker/releases/download/v0.1.0/hunker-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "910c61cc9b79baf8c2e15aef86ca7bf2bc088a69791903562643b6d2c1c740e0"
    end
    on_intel do
      url "https://github.com/sharno/hunker/releases/download/v0.1.0/hunker-v0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "f62351f25ae208ae7c39ef6680553d16608868a7df62f9b5fe9442353bfe4a9c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/sharno/hunker/releases/download/v0.1.0/hunker-v0.1.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "eb98f000cd1f5215cb8911d3b0dd601ff1ee9f580db297530bb932a38b580668"
    end
    on_intel do
      url "https://github.com/sharno/hunker/releases/download/v0.1.0/hunker-v0.1.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "28069187252ec1080077b103c17fce8e73f63ba68fae7fb5820d4d593f64abad"
    end
  end

  def install
    bin.install "hunker"
  end

  def caveats
    <<~EOS
      Run `hunker` or `brew services start hunker`, then open
      http://127.0.0.1:5173. Private repositories use GITHUB_TOKEN or `gh auth`.
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

    port = free_port
    pid = spawn({ "HUNKER_PORT" => port.to_s, "HUNKER_CONFIG_FILE" => (testpath/"settings.json").to_s },
                bin/"hunker")
    begin
      sleep 2
      assert_match "<title>Hunker", shell_output("curl -s http://127.0.0.1:#{port}/")
    ensure
      Process.kill("TERM", pid)
      Process.wait(pid)
    end
  end
end
