require 'formula'

class Hhvm < Formula
  url 'https://github.com/facebook/hhvm/archive/HHVM-2.4.2.tar.gz'
  homepage 'https://github.com/facebook/hhvm/tree/HHVM-2.4.2'
  sha1 '6d731d5ebd09ec268115f963973d17adf8391c29'
  head 'https://github.com/facebook/hhvm.git'

  option 'with-debug', 'Enable debug build.'
  option 'with-mariadb', 'Use mariadb as mysql package.'
  option 'with-percona-server', 'Use percona-server as mysql package.'
  option 'with-system-mysql', 'Try to use the mysql package installed on your system.'

  depends_on 'cmake' => :build
  depends_on 'libtool' => :build
  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'pkg-config' => :build

  #Standard packages
  depends_on 'freetype'
  depends_on 'gettext'
  depends_on 'mcrypt'
  depends_on 'glog'
  depends_on 'oniguruma'
  depends_on 're2c'
  depends_on 'libelf'
  depends_on 'readline'
  depends_on 'pcre'
  depends_on 'gd'
  depends_on 'imagemagick'
  depends_on 'icu4c'
  depends_on 'libmemcached'
  depends_on 'tbb'
  depends_on 'boost'
  depends_on 'imagemagick'
#  depends_on 'binutils'
  depends_on 'ncurses'
  depends_on 'libssh2'
  depends_on 'curl'
  depends_on 'imap-uw'
  depends_on 'jpeg'
  depends_on 'libpng'
  depends_on 'unixodbc'
  depends_on 'boost'

  #Custome packages
  if build.stable?
    depends_on 'folly'
  end

  depends_on 'jemallocfb'
  depends_on 'libdwarf'
  depends_on 'libeventfb'
  depends_on 'binutilsfb'

  #MySQL packages
  if build.with? 'mariadb'
    depends_on 'mariadb'
  elsif build.with? 'percona-server'
    depends_on 'percona-server'
  elsif build.without? 'system-mysql'
    depends_on 'mysql'
    depends_on 'mysql-connector-c++'
    if MacOS.version < :mavericks
      depends_on 'mysql-connector-c'
    end
  end

  def patches
    DATA
  end

  def install
    args = [
      ".",
      "-DCMAKE_CXX_COMPILER=/usr/bin/clang++",
      "-DCMAKE_C_COMPILER=/usr/bin/clang",
      "-DCMAKE_ASM_COMPILER=/usr/bin/clang",
      "-DLIBIBERTY_LIB=#{Formula['binutilsfb'].lib}/x86_64/libiberty.a",
      "-DCMAKE_INCLUDE_PATH=\"#{HOMEBREW_PREFIX}/include:/usr/include\"",
      "-DCMAKE_LIBRARY_PATH=\"#{HOMEBREW_PREFIX}/lib:/usr/lib\"",
      "-DLIBEVENT_LIB=#{Formula['libeventfb'].lib}/libevent.dylib",
      "-DLIBEVENT_INCLUDE_DIR=#{Formula['libeventfb'].include}",
      "-DICU_INCLUDE_DIR=#{Formula['icu4c'].include}",
      "-DICU_LIBRARY=#{Formula['icu4c'].lib}/libicuuc.dylib",
      "-DICU_I18N_LIBRARY=#{Formula['icu4c'].lib}/libicui18n.dylib",
      "-DICU_DATA_LIBRARY=#{Formula['icu4c'].lib}/libicudata.dylib",
      "-DREADLINE_INCLUDE_DIR=#{Formula['readline'].include}",
      "-DREADLINE_LIBRARY=#{Formula['readline'].lib}/libreadline.dylib",
      "-DNCURSES_LIBRARY=#{Formula['ncurses'].lib}/libncurses.dylib",
      "-DCURL_INCLUDE_DIR=#{Formula['curl'].include}",
      "-DCURL_LIBRARY=#{Formula['curl'].lib}/libcurl.dylib",
      "-DBOOST_INCLUDEDIR=#{Formula['boost'].include}",
      "-DBOOST_LIBRARYDIR=#{Formula['boost'].lib}",
      "-DBoost_USE_STATIC_LIBS=ON",
      "-DJEMALLOC_INCLUDE_DIR=#{Formula['jemallocfb'].include}",
      "-DJEMALLOC_LIB=#{Formula['jemallocfb'].lib}/libjemalloc.dylib",
      "-DLIBINTL_LIBRARIES=#{Formula['gettext'].lib}/libintl.dylib",
      "-DLIBINTL_INCLUDE_DIR=#{Formula['gettext'].include}",
      "-DLIBDWARF_LIBRARIES=#{Formula['libdwarf'].lib}/libdwarf.3.dylib",
      "-DDWARF_INCLUDE_DIR=#{Formula['libdwarf'].include}",
      "-DLIBELF_INCLUDE_DIRS=#{Formula['libelf'].include}/libelf",
      "-DCMAKE_INCLUDE_PATH=#{Formula['binutilsfb'].include}",
      "-DCCLIENT_INCLUDE_PATH=#{Formula['imap-uw'].include}/imap",
      "-DLIBGLOG_INCLUDE_DIR=#{Formula['glog'].include}",
      "-DLIBJPEG_INCLUDE_DIRS=#{Formula['jpeg'].include}",
      "-DLIBMEMCACHED_INCLUDE_DIR=#{Formula['libmemcached'].include}",
      "-DLIBODBC_INCLUDE_DIRS=#{Formula['unixodbc'].include}",
      "-DLIBPNG_INCLUDE_DIRS=#{Formula['libpng'].include}",
      "-DMcrypt_INCLUDE_DIR=#{Formula['mcrypt'].include}",
      "-DONIGURUMA_INCLUDE_DIR=#{Formula['oniguruma'].include}",
      "-DPCRE_INCLUDE_DIR=#{Formula['pcre'].include}",
      "-DTBB_INCLUDE_DIRS=#{Formula['tbb'].include}",
      "-DTEST_TBB_INCLUDE_DIR=#{Formula['tbb'].include}",
      "-DFREETYPE_INCLUDE_DIRS=#{Formula['freetype'].include}/freetype2",
      "-DLIBMAGICKWAND_INCLUDE_DIRS=#{Formula['imagemagick'].include}/ImageMagick-6",
      "-DLIBMAGICKWAND_LIBRARIES=#{Formula['imagemagick'].lib}/libMagickWand-6.Q16.dylib",
      "-DCMAKE_INSTALL_PREFIX=#{prefix}"
    ]

    if build.with? 'mariadb'
      args << "-DMYSQL_INCLUDE_DIR=#{Formula['mariadb'].include}/mysql"
    elsif build.with? 'percona-server'
      args << "-DMYSQL_INCLUDE_DIR=#{Formula['percona-server'].include}/mysql"
    elsif build.without? 'system-mysql'
      args << "-DMYSQL_INCLUDE_DIR=#{Formula['mysql'].include}/mysql"
    end

    if build.with? 'debug'
      args << '-DCMAKE_BUILD_TYPE=Debug'
    end

    ENV['HPHP_HOME'] = Dir.pwd

    if build.stable?
      system "rm -rf hphp/submodules/folly"
      system "ln -s #{Formula['folly'].opt_prefix} hphp/submodules/folly"
    end

    system "cmake", *args
    system "make", "-j#{ENV.make_jobs}"
    system "make install"
  end

  def caveats
    <<-EOS.undent
      If you have XQuartz (X11) installed:
        To temporarily remove a symbolic link at '/usr/X11R6' in order
        to successfully install HHVM.

        $ sudo rm /usr/X11R6
        $ sudo ln -s /opt/X11 /usr/X11R6
    EOS
  end
end

__END__
diff --git a/hphp/runtime/ext/gd/libgd/gdft.cpp b/hphp/runtime/ext/gd/libgd/gdft.cpp
index e2a511b..c1a63be 100644
--- a/hphp/runtime/ext/gd/libgd/gdft.cpp
+++ b/hphp/runtime/ext/gd/libgd/gdft.cpp
@@ -61,7 +61,7 @@
 #else

 #include "gdcache.h"
-#include <freetype/config/ftheader.h>
+#include <ft2build.h>
 #include FT_FREETYPE_H
 #include FT_GLYPH_H

diff --git a/HPHPFindLibs.cmake b/HPHPFindLibs.cmake
index d4ec7c1..2d0a2b3 100644
--- a/HPHPFindLibs.cmake
+++ b/HPHPFindLibs.cmake
@@ -27,6 +27,10 @@ if (LIBDL_INCLUDE_DIRS)
 	endif()
 endif()
 
+foreach(path ${CMAKE_INCLUDE_PATH})
+  include_directories(${path})
+endforeach()
+
 # boost checks
 find_package(Boost 1.49.0 COMPONENTS system program_options filesystem regex REQUIRED)
 include_directories(${Boost_INCLUDE_DIRS})
@@ -380,14 +384,14 @@ if (LINUX OR APPLE)
 endif()
 
 FIND_LIBRARY (BFD_LIB bfd)
-FIND_LIBRARY (BINUTIL_LIB iberty)
+FIND_LIBRARY (LIBIBERTY_LIB iberty)
 
 if (NOT BFD_LIB)
 	message(FATAL_ERROR "You need to install binutils")
 endif()
 
-if (NOT BINUTIL_LIB)
-	message(FATAL_ERROR "You need to install binutils")
+if (NOT LIBIBERTY_LIB)
+	message(FATAL_ERROR "You need to install libiberty (usually bundled with binutils)")
 endif()
 
 if (FREEBSD)
@@ -474,7 +478,7 @@ if (APPLE)
 endif()
 
 	target_link_libraries(${target} ${BFD_LIB})
-	target_link_libraries(${target} ${BINUTIL_LIB})
+	target_link_libraries(${target} ${LIBIBERTY_LIB})
 if (${LIBPTHREAD_LIBRARIES})
 	target_link_libraries(${target} ${LIBPTHREAD_LIBRARIES})
 endif()
