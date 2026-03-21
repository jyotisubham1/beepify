class Beepify < Formula
  desc "Play a sound when your terminal throws an error — activate it like a venv"
  homepage "https://github.com/jyotisubham1/beepify"
  license "MIT"

  url "https://github.com/jyotisubham1/beepify/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "3343d3bc5e79cb909c76305a9b54f3deb33d38da49485bdf605e9f1020c4c450"
  version "1.0.4"

  depends_on "ffmpeg"
  depends_on :macos

  def install
    # Install platform scripts
    libexec.install "mac", "linux", "windows", "shared", "sounds", "shell", "bin"

    # Make scripts executable
    system "chmod", "-R", "+x", libexec/"mac"
    system "chmod", "-R", "+x", libexec/"linux"
    system "chmod", "+x", libexec/"bin/beepify"

    # Wire up the beepify CLI to Homebrew's bin
    bin.install_symlink libexec/"bin/beepify"

    # Set HOMEBREW_PREFIX so the CLI can find its home
    inreplace libexec/"bin/beepify",
      'BEEPIFY_HOME="$(cd "$(dirname "$0")/.." && pwd)"',
      "BEEPIFY_HOME=\"#{opt_libexec}\""
  end

  def caveats
    <<~EOS
      Add shell integration to your ~/.zshrc so that
      `beepify activate` and `beepify deactivate` work:

        echo 'source $(brew --prefix)/opt/beepify/libexec/shell/beepify.zsh' >> ~/.zshrc

      Then restart your terminal (or run the source command once now).

      ─────────────────────────────────────
      Quick start:

        beepify select      # pick a sound
        beepify activate    # turn on error sounds
        beepify deactivate  # turn off

      To auto-convert custom sounds dropped into sounds/custom/:

        beepify watch       # start folder watcher
        beepify watch stop  # stop it
      ─────────────────────────────────────
    EOS
  end

  test do
    assert_predicate bin/"beepify", :executable?
    assert_match "beepify", shell_output("#{bin}/beepify help")
  end
end
