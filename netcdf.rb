require 'formula'

class Netcdf < Formula
  homepage 'http://www.unidata.ucar.edu/software/netcdf'
  url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-4.3.2.tar.gz'
  sha1 '6e1bacab02e5220954fe0328d710ebb71c071d19'

  bottle do
    root_url 'https://juliabottles.s3.amazonaws.com'
    cellar :any
    sha1 '64235bcb7f603251551f22c513b0594446dd9ea2' => :lion
    sha1 '4a02f21386f9e6a386213da3d1ac1ee7f021807a' => :mavericks
    sha1 '7bcbab83681835803cb1aa368f669016d7e97b3f' => :mountain_lion
    sha1 "db4e7179a7bd919fdba881bcecf6b6cbd89b3147" => :yosemite
  end

  depends_on :fortran if build.include? 'enable-fortran'
  depends_on 'staticfloat/juliadeps/hdf5'

  option 'enable-fortran', 'Compile Fortran bindings'
  option 'disable-cxx', "Don't compile C++ bindings"
  option 'enable-cxx-compat', 'Compile C++ bindings for compatibility'

  resource 'cxx' do
    url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-cxx4-4.2.tar.gz'
    sha1 '59628c9f06c211a47517fc00d8b068da159ffa9d'
  end

  resource 'cxx-compat' do
    url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-cxx-4.2.tar.gz'
    sha1 'bab9b2d873acdddbdbf07ab35481cd0267a3363b'
  end

  resource 'fortran' do
    url 'http://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.2.tar.gz'
    sha1 'f1887314455330f4057bc8eab432065f8f6f74ef'
  end

  def install
    if build.include? 'enable-fortran'
      # fix for ifort not accepting the --force-load argument, causing
      # the library libnetcdff.dylib to be missing all the f90 symbols.
      # http://www.unidata.ucar.edu/software/netcdf/docs/known_problems.html#intel-fortran-macosx
      # https://github.com/mxcl/homebrew/issues/13050
      ENV['lt_cv_ld_force_load'] = 'no' if ENV.fc == 'ifort'
    end

    common_args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-static
      --enable-shared
    ]

    args = common_args.clone
    args.concat %w[--enable-netcdf4 --disable-doxygen]

    system './configure', *args
    system 'make install'

    # Add newly created installation to paths so that binding libraries can
    # find the core libs.
    ENV.prepend_path 'PATH', bin
    ENV.prepend 'CPPFLAGS', "-I#{include}"
    ENV.prepend 'LDFLAGS', "-L#{lib}"

    resource('cxx').stage do
      system './configure', *common_args
      system 'make install'
    end unless build.include? 'disable-cxx'

    resource('cxx-compat').stage do
      system './configure', *common_args
      system 'make install'
    end if build.include? 'enable-cxx-compat'

    resource('fortran').stage do
      system './configure', *common_args
      system 'make install'
    end if build.include? 'enable-fortran'
  end
end
