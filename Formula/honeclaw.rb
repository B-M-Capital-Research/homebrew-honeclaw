class Honeclaw < Formula
  desc "CLI bundle for the Hone investment research assistant"
  homepage "https://github.com/B-M-Capital-Research/honeclaw"
  license "MIT"
  version "0.15.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.15.2/honeclaw-darwin-aarch64.tar.gz"
      sha256 "bfe5a6e65391471f395bae6345f112ee3c6c774afdbe50b0069bf3497365d548"
    else
      url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.15.2/honeclaw-darwin-x86_64.tar.gz"
      sha256 "dfdd4fa328e2daa8231dd68fd8a55e3a5edfa6a1d93d1838ea8664740e3ec5b3"
    end
  end

  on_linux do
    url "https://github.com/B-M-Capital-Research/honeclaw/releases/download/v0.15.2/honeclaw-linux-x86_64.tar.gz"
    sha256 "82aeb03a58b6f02b9a28b7a5a329529ae5313af37a6ffd18c6ea8fd1ee9ddfc4"
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
      HONE_PUBLIC_WEB_DIST_DIR="${HONE_PUBLIC_WEB_DIST_DIR:-#{libexec}/share/honeclaw/web-public}"

      mkdir -p "$HONE_HOME"
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
      export HONE_PUBLIC_WEB_DIST_DIR

      if [[ ! -x "#{libexec}/bin/hone-cli" ]]; then
        echo "installed Hone CLI binary is missing: #{libexec}/bin/hone-cli" >&2
        echo "reinstall or upgrade the Hone Homebrew package, then retry" >&2
        exit 1
      fi

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
        hone-cli web admin-ui
        hone-cli web user-ui
    EOS
  end

  test do
    output = shell_output("#{bin}/hone-cli --help")
    assert_match "Hone CLI", output
  end
end
