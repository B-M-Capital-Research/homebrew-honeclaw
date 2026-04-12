class Honeclaw < Formula
  desc "CLI bundle for the Hone investment research assistant"
  homepage "https://github.com/B-M-Capital-Research/honeclaw"
  license "MIT"
  version "0.1.6"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.1.6/honeclaw-darwin-aarch64.tar.gz"
      sha256 "c0d15ba40609b1757a3edea3cd791b54ab0de93e2b27852ec4f8bf1dd043a7cc"
    else
      url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.1.6/honeclaw-darwin-x86_64.tar.gz"
      sha256 "f06cfe2588c6de83244817bb64b5630ec7e70b89f5d89f71dcf4a5d0ee41303c"
    end
  end

  on_linux do
    url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.1.6/honeclaw-linux-x86_64.tar.gz"
    sha256 "e70efdb1ea509836d16971d9ca9652bc34a955fba3aa1dfafd4167d2debab133"
  end

  def install
    libexec.install "bin", "share"

    (bin/"hone-cli").write <<~EOS
      #!/usr/bin/env bash
      set -euo pipefail

      HONE_HOME="${HONE_HOME:-$HOME/.honeclaw}"
      HONE_DATA_DIR="${HONE_DATA_DIR:-$HONE_HOME/data}"
      HONE_USER_CONFIG_PATH="${HONE_USER_CONFIG_PATH:-$HONE_HOME/config.yaml}"
      HONE_SKILLS_DIR="${HONE_SKILLS_DIR:-#{libexec}/share/honeclaw/skills}"
      HONE_WEB_DIST_DIR="${HONE_WEB_DIST_DIR:-#{libexec}/share/honeclaw/web}"

      mkdir -p "$HONE_DATA_DIR/runtime"

      if [[ "$HONE_USER_CONFIG_PATH" == "$HONE_HOME/config.yaml" && ! -f "$HONE_USER_CONFIG_PATH" ]]; then
        cp "#{libexec}/share/honeclaw/config.example.yaml" "$HONE_USER_CONFIG_PATH"
      fi

      if [[ ! -f "$HONE_HOME/soul.md" ]]; then
        cp "#{libexec}/share/honeclaw/soul.md" "$HONE_HOME/soul.md"
      fi

      export HONE_HOME
      export HONE_INSTALL_ROOT="#{libexec}"
      export HONE_USER_CONFIG_PATH
      export HONE_DATA_DIR
      export HONE_SKILLS_DIR
      export HONE_WEB_DIST_DIR

      exec "#{libexec}/bin/hone-cli" "$@"
    EOS

    chmod 0755, bin/"hone-cli"
  end

  def caveats
    <<~EOS
      Hone stores user config in ~/.honeclaw/config.yaml and runtime data in ~/.honeclaw/data.

      Next steps:
        hone-cli doctor
        hone-cli onboard
        hone-cli start
    EOS
  end

  test do
    output = shell_output("#{bin}/hone-cli --help")
    assert_match "Hone CLI", output
  end
end
