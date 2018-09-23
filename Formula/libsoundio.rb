class Libsoundio < Formula
  desc "Cross-platform audio input and output"
  homepage "http://libsound.io"
  url "https://github.com/andrewrk/libsoundio/archive/1.1.0.tar.gz"
  sha256 "ba0b21397cb3e29dc8f51ed213ae27625f05398c01aefcfbaa860fab42a84281"

  bottle do
    cellar :any
    sha256 "f62f2b57eba5227047b10254946035cc72b909bef698eecb803faad223b96d76" => :mojave
    sha256 "5bc5fcbcb3e6475d59f7a3b95c494f6e776a6e8b5b903217267195dfd8ed761a" => :high_sierra
    sha256 "1aa2aab043cb9358898b7c9f3c33c727e72342b414048620be561cfca8bc839a" => :sierra
    sha256 "33e6599cba76ac835cb2ffc597f8358a8b13c7cd19c7ce9b85a3d3ff60ec4327" => :el_capitan
    sha256 "594c0042c86a0a6aeca3b7286435b3cc9593ffa158f921092df90f0aef3a865e" => :yosemite
  end

  depends_on "cmake" => :build

  # fatal error: 'stdatomic.h' file not found
  depends_on :macos => :yosemite

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
    (lib/"pkgconfig/soundio.pc").write pc_file
  end

  def pc_file; <<~EOS
    prefix=#{prefix}
    libdir=${prefix}/lib
    includedir=${prefix}/include

    Name: libsoundio
    Description: Cross-platform audio input and output
    Version: #{version}
    Requires:
    Libs: -L${libdir} -lsoundio
    Cflags: -I${includedir}
  EOS
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <soundio/soundio.h>

      int main() {
        struct SoundIo *soundio = soundio_create();

        if (!soundio) { return 1; }
        if (soundio_connect(soundio)) return 1;

        soundio_flush_events(soundio);
        soundio_destroy(soundio);

        return 0;
      }
    EOS
    flags = `pkg-config --libs --cflags soundio`.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
