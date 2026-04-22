class Honeclaw < Formula
  desc "CLI bundle for the Hone investment research assistant"
  homepage "https://github.com/B-M-Capital-Research/honeclaw"
  license "MIT"
  version "0.2.4"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.2.4/honeclaw-darwin-aarch64.tar.gz"
      sha256 "b5fc4be06186ae5da4076bfd11e970d30bf5422eaffef568e94743d833c51d8f"
    else
      url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.2.4/honeclaw-darwin-x86_64.tar.gz"
      sha256 "d0b7ee346703f88ab544a5cec388dc87a50f151517342768e1ea654a04c9229e"
    end
  end

  on_linux do
    url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.2.4/honeclaw-linux-x86_64.tar.gz"
    sha256 "9782b147293d17f7dbfdbc306bb843fce7d73cfeec3d7680e843fe6cc730473e"
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

      To remove local Hone data before uninstalling, run:
        hone-cli cleanup

      To uninstall the Homebrew package itself, run:
        brew uninstall honeclaw

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
