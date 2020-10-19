$benchnum  = '557';
$benchname = 'xz_r';
$exename   = 'xz_r';
$benchlang = 'C';
@base_exe  = ($exename);

$calctol = 0;

use Config;
$bench_flags  = '-DSPEC_AUTO_BYTEORDER=0x'.$Config{'byteorder'};
$bench_flags .= ' -DHAVE_CONFIG_H=1 -DSPEC_MEM_IO -DSPEC_XZ -DSPEC_AUTO_SUPPRESS_OPENMP';
$bench_flags .= ' '.join(' ', qw(
    -I.
    -Ispec_mem_io
    -Isha-2
    -Icommon
    -Iliblzma/api
    -Iliblzma/lzma
    -Iliblzma/common
    -Iliblzma/check
    -Iliblzma/simple
    -Iliblzma/delta
    -Iliblzma/lz
    -Iliblzma/rangecoder
    ));

@sources = (qw(
    spec.c
    spec_xz.c
    pxz.c
    common/tuklib_physmem.c
    liblzma/common/common.c
    liblzma/common/block_util.c
    liblzma/common/easy_preset.c
    liblzma/common/filter_common.c
    liblzma/common/hardware_physmem.c
    liblzma/common/index.c
    liblzma/common/stream_flags_common.c
    liblzma/common/vli_size.c
    liblzma/common/alone_encoder.c
    liblzma/common/block_buffer_encoder.c
    liblzma/common/block_encoder.c
    liblzma/common/block_header_encoder.c
    liblzma/common/easy_buffer_encoder.c
    liblzma/common/easy_encoder.c
    liblzma/common/easy_encoder_memusage.c
    liblzma/common/filter_buffer_encoder.c
    liblzma/common/filter_encoder.c
    liblzma/common/filter_flags_encoder.c
    liblzma/common/index_encoder.c
    liblzma/common/stream_buffer_encoder.c
    liblzma/common/stream_encoder.c
    liblzma/common/stream_flags_encoder.c
    liblzma/common/vli_encoder.c
    liblzma/common/alone_decoder.c
    liblzma/common/auto_decoder.c
    liblzma/common/block_buffer_decoder.c
    liblzma/common/block_decoder.c
    liblzma/common/block_header_decoder.c
    liblzma/common/easy_decoder_memusage.c
    liblzma/common/filter_buffer_decoder.c
    liblzma/common/filter_decoder.c
    liblzma/common/filter_flags_decoder.c
    liblzma/common/index_decoder.c
    liblzma/common/index_hash.c
    liblzma/common/stream_buffer_decoder.c
    liblzma/common/stream_decoder.c
    liblzma/common/stream_flags_decoder.c
    liblzma/common/vli_decoder.c
    liblzma/check/check.c
    liblzma/check/crc32_table.c
    liblzma/check/crc32_fast.c
    liblzma/check/crc64_table.c
    liblzma/check/crc64_fast.c
    liblzma/check/sha256.c
    liblzma/lz/lz_encoder.c
    liblzma/lz/lz_encoder_mf.c
    liblzma/lz/lz_decoder.c
    liblzma/lzma/lzma_encoder.c
    liblzma/lzma/lzma_encoder_presets.c
    liblzma/lzma/lzma_encoder_optimum_fast.c
    liblzma/lzma/lzma_encoder_optimum_normal.c
    liblzma/lzma/fastpos_table.c
    liblzma/lzma/lzma_decoder.c
    liblzma/lzma/lzma2_encoder.c
    liblzma/lzma/lzma2_decoder.c
    liblzma/rangecoder/price_table.c
    liblzma/delta/delta_common.c
    liblzma/delta/delta_encoder.c
    liblzma/delta/delta_decoder.c
    liblzma/simple/simple_coder.c
    liblzma/simple/simple_encoder.c
    liblzma/simple/simple_decoder.c
    liblzma/simple/x86.c
    liblzma/simple/powerpc.c
    liblzma/simple/ia64.c
    liblzma/simple/arm.c
    liblzma/simple/armthumb.c
    liblzma/simple/sparc.c
    xz/args.c
    xz/coder.c
    xz/file_io.c
    xz/hardware.c
    xz/list.c
    xz/main.c
    xz/message.c
    xz/options.c
    xz/signals.c
    xz/util.c
    common/tuklib_open_stdxxx.c
    common/tuklib_progname.c
    common/tuklib_exit.c
    common/tuklib_cpucores.c
    common/tuklib_mbstr_width.c
    common/tuklib_mbstr_fw.c
    spec_mem_io/spec_mem_io.c
    sha-2/sha512.c
    ));

sub invoke {
    my ($me) = @_;
    my (@rc);

    my @temp = main::read_file('control');
    my $exe = $me->exe_file;

    foreach my $args (@temp) {
        next if $args =~ m/^\s*(#|$)/;
        my ($name, $size, $sum, $min, $max, @levels) = split(/\s+/, $args);
        @levels = grep { /^\de?/ } @levels;
        next if $size <= 0 || $sum eq '' || @levels == 0;
        my $leveltext = join('_', @levels);
        push @rc, (
            {
                'command' => $exe,
                'args'    => [ "${name}.xz", $size, $sum, $min, $max, @levels ],
                'output'  => "$name-$size-$leveltext.out",
                'error'   => "$name-$size-$leveltext.err",
            }
        );
    }
    return @rc;
}

my @common_tuklib = (qw(
    config.h
    common/sysdefs.h
    common/tuklib_common.h
    common/tuklib_config.h
    ));
my @liblzma_api = (qw(
    liblzma/api/lzma.h
    liblzma/api/lzma/base.h
    liblzma/api/lzma/bcj.h
    liblzma/api/lzma/block.h
    liblzma/api/lzma/check.h
    liblzma/api/lzma/container.h
    liblzma/api/lzma/delta.h
    liblzma/api/lzma/filter.h
    liblzma/api/lzma/hardware.h
    liblzma/api/lzma/index.h
    liblzma/api/lzma/index_hash.h
    liblzma/api/lzma/lzma.h
    liblzma/api/lzma/stream_flags.h
    liblzma/api/lzma/version.h
    liblzma/api/lzma/vli.h
    ));
my @xz_inc = (qw(
    xz/args.h
    xz/coder.h
    xz/file_io.h
    xz/hardware.h
    xz/list.h
    xz/main.h
    xz/message.h
    xz/options.h
    xz/private.h
    xz/signals.h
    xz/util.h
    ));

%srcdeps = (
    'common/tuklib_cpucores.c' => [
        'common/tuklib_cpucores.h',
        @common_tuklib,
    ],
    'common/tuklib_exit.c' => [
        qw(
        common/tuklib_exit.h
        common/tuklib_gettext.h
        common/tuklib_progname.h
        ),
        @common_tuklib,
    ],
    'common/tuklib_mbstr_fw.c' => [
        'common/tuklib_mbstr.h',
        @common_tuklib,
    ],
    'common/tuklib_mbstr_width.c' => [
        'common/tuklib_mbstr.h',
        @common_tuklib,
    ],
    'common/tuklib_open_stdxxx.c' => [
        'common/tuklib_open_stdxxx.h',
        @common_tuklib,
    ],
    'common/tuklib_physmem.c' => [
        'common/tuklib_physmem.h',
        @common_tuklib,
    ],
    'common/tuklib_progname.c' => [
        'common/tuklib_progname.h',
        @common_tuklib,
    ],
    'liblzma/check/check.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/check/crc32_fast.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/check/crc_macros.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/check/crc32_small.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/check/crc32_table.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/crc32_table_le.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/check/crc64_fast.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/check/crc_macros.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/check/crc64_small.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/check/crc64_table.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/crc64_table_le.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/check/sha256.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/alone_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/alone_decoder.h
        liblzma/common/common.h
        liblzma/lz/lz_decoder.h
        liblzma/lzma/lzma_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/alone_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/lzma/lzma_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/auto_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/alone_decoder.h
        liblzma/common/common.h
        liblzma/common/stream_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/block_buffer_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/block_decoder.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/block_buffer_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/block_encoder.h
        liblzma/common/common.h
        liblzma/common/filter_encoder.h
        liblzma/lzma/lzma2_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/block_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/block_decoder.h
        liblzma/common/common.h
        liblzma/common/filter_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/block_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/block_encoder.h
        liblzma/common/common.h
        liblzma/common/filter_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/block_header_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/block_header_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/block_util.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/index.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/common.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/easy_buffer_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/easy_preset.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/easy_decoder_memusage.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/easy_preset.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/easy_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/easy_preset.h
        liblzma/common/stream_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/easy_encoder_memusage.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/easy_preset.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/easy_preset.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/easy_preset.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/filter_buffer_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/filter_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/filter_buffer_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/filter_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/filter_common.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/filter_common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/filter_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/filter_common.h
        liblzma/common/filter_decoder.h
        liblzma/delta/delta_common.h
        liblzma/delta/delta_decoder.h
        liblzma/lzma/lzma2_decoder.h
        liblzma/lzma/lzma_decoder.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/filter_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/filter_common.h
        liblzma/common/filter_encoder.h
        liblzma/delta/delta_common.h
        liblzma/delta/delta_encoder.h
        liblzma/lzma/lzma2_encoder.h
        liblzma/lzma/lzma_encoder.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/filter_flags_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/filter_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/filter_flags_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/filter_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/hardware_physmem.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        common/tuklib_physmem.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/index.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/index.h
        liblzma/common/stream_flags_common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/index_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        liblzma/common/index.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/index_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        liblzma/common/index.h
        liblzma/common/index_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/index_hash.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        liblzma/common/index.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/stream_buffer_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/stream_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/stream_buffer_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/index.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/stream_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/block_decoder.h
        liblzma/common/common.h
        liblzma/common/stream_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/stream_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/block_encoder.h
        liblzma/common/common.h
        liblzma/common/index_encoder.h
        liblzma/common/stream_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/stream_flags_common.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/stream_flags_common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/stream_flags_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/stream_flags_common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/stream_flags_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/common/stream_flags_common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/vli_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/vli_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/common/vli_size.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/delta/delta_common.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/delta/delta_common.h
        liblzma/delta/delta_private.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/delta/delta_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/delta/delta_common.h
        liblzma/delta/delta_decoder.h
        liblzma/delta/delta_private.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/delta/delta_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/delta/delta_common.h
        liblzma/delta/delta_encoder.h
        liblzma/delta/delta_private.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lz/lz_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/lz/lz_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lz/lz_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        liblzma/lz/lz_encoder.h
        liblzma/lz/lz_encoder_hash.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lz/lz_encoder_mf.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/check/check.h
        liblzma/common/common.h
        liblzma/lz/lz_encoder.h
        liblzma/lz/lz_encoder_hash.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lzma/fastpos_table.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/lzma/fastpos.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lzma/fastpos_tablegen.c' => [
        'liblzma/lzma/fastpos.h'
    ],
    'liblzma/lzma/lzma2_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/lz/lz_decoder.h
        liblzma/lzma/lzma2_decoder.h
        liblzma/lzma/lzma_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lzma/lzma2_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/lz/lz_encoder.h
        liblzma/lzma/fastpos.h
        liblzma/lzma/lzma2_encoder.h
        liblzma/lzma/lzma_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lzma/lzma_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/lz/lz_decoder.h
        liblzma/lzma/lzma_common.h
        liblzma/lzma/lzma_decoder.h
        liblzma/rangecoder/range_common.h
        liblzma/rangecoder/range_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lzma/lzma_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/lz/lz_encoder.h
        liblzma/lzma/fastpos.h
        liblzma/lzma/lzma2_encoder.h
        liblzma/lzma/lzma_common.h
        liblzma/lzma/lzma_encoder.h
        liblzma/lzma/lzma_encoder_private.h
        liblzma/rangecoder/price.h
        liblzma/rangecoder/range_common.h
        liblzma/rangecoder/range_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lzma/lzma_encoder_optimum_fast.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/lz/lz_encoder.h
        liblzma/lzma/lzma_common.h
        liblzma/lzma/lzma_encoder.h
        liblzma/lzma/lzma_encoder_private.h
        liblzma/rangecoder/price.h
        liblzma/rangecoder/range_common.h
        liblzma/rangecoder/range_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lzma/lzma_encoder_optimum_normal.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/lz/lz_encoder.h
        liblzma/lzma/fastpos.h
        liblzma/lzma/lzma_common.h
        liblzma/lzma/lzma_encoder.h
        liblzma/lzma/lzma_encoder_private.h
        liblzma/rangecoder/price.h
        liblzma/rangecoder/range_common.h
        liblzma/rangecoder/range_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/lzma/lzma_encoder_presets.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/rangecoder/price_table.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/rangecoder/price.h
        liblzma/rangecoder/range_common.h
        liblzma/rangecoder/range_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/rangecoder/price_tablegen.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/rangecoder/price.h
        liblzma/rangecoder/range_common.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/simple/arm.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_private.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/simple/armthumb.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_private.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/simple/ia64.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_private.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/simple/powerpc.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_private.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/simple/simple_coder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_private.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/simple/simple_decoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_decoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/simple/simple_encoder.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_encoder.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/simple/sparc.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_private.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'liblzma/simple/x86.c' => [
        qw(
        common/mythread.h
        common/tuklib_integer.h
        liblzma/common/common.h
        liblzma/simple/simple_coder.h
        liblzma/simple/simple_private.h
        ),
        @common_tuklib,
        @liblzma_api,
    ],
    'sha-2/sha512.c' => [
        'sha-2/sha512.h'
    ],
    'pxz.c' => [
        'spec_mem_io/spec_mem_io.h',
        @liblzma_api,
    ],
    'spec.c' => [
        'spec_mem_io/spec_mem_io.h',
        @liblzma_api,
    ],
    'spec_mem_io/spec_mem_io.c' => [
        qw(
        sha-2/sha512.h
        spec_mem_io/spec_mem_io.h
        ),
        @liblzma_api,
    ],
    'spec_xz.c' => [
        'spec_mem_io/spec_mem_io.h',
        @liblzma_api,
    ],
    'xz/args.c' => [
        qw(
        common/mythread.h
        common/tuklib_exit.h
        common/tuklib_gettext.h
        common/tuklib_mbstr.h
        common/tuklib_progname.h
        spec_mem_io/spec_mem_io.h
        ),
        @common_tuklib,
        @liblzma_api,
        @xz_inc,
    ],
    'xz/coder.c' => [
        qw(
        common/mythread.h
        common/tuklib_exit.h
        common/tuklib_gettext.h
        common/tuklib_mbstr.h
        common/tuklib_progname.h
        spec_mem_io/spec_mem_io.h
        ),
        @common_tuklib,
        @liblzma_api,
        @xz_inc,
    ],
    'xz/file_io.c' => [
        qw(
        common/mythread.h
        common/tuklib_exit.h
        common/tuklib_gettext.h
        common/tuklib_mbstr.h
        common/tuklib_open_stdxxx.h
        common/tuklib_progname.h
        spec_mem_io/spec_mem_io.h
        ),
        @common_tuklib,
        @liblzma_api,
        @xz_inc,
    ],
    'xz/hardware.c' => [
        qw(
        common/mythread.h
        common/tuklib_cpucores.h
        common/tuklib_exit.h
        common/tuklib_gettext.h
        common/tuklib_mbstr.h
        common/tuklib_progname.h
        spec_mem_io/spec_mem_io.h
        ),
        @common_tuklib,
        @liblzma_api,
        @xz_inc,
    ],
    'xz/list.c' => [
        qw(
        common/mythread.h
        common/tuklib_exit.h
        common/tuklib_gettext.h
        common/tuklib_integer.h
        common/tuklib_mbstr.h
        common/tuklib_progname.h
        spec_mem_io/spec_mem_io.h
        ),
        @common_tuklib,
        @liblzma_api,
        @xz_inc,
    ],
    'xz/main.c' => [
        qw(
        common/mythread.h
        common/tuklib_exit.h
        common/tuklib_gettext.h
        common/tuklib_mbstr.h
        common/tuklib_progname.h
        spec_mem_io/spec_mem_io.h
        ),
        @common_tuklib,
        @liblzma_api,
        @xz_inc,
    ],
    'xz/message.c' => [
        qw(
        common/mythread.h
        common/tuklib_exit.h
        common/tuklib_gettext.h
        common/tuklib_mbstr.h
        common/tuklib_progname.h
        spec_mem_io/spec_mem_io.h
        ),
        @common_tuklib,
        @liblzma_api,
        @xz_inc,
    ],
    'xz/options.c' => [
        qw(
        common/mythread.h
        common/tuklib_exit.h
        common/tuklib_gettext.h
        common/tuklib_mbstr.h
        common/tuklib_progname.h
        spec_mem_io/spec_mem_io.h
        ),
        @common_tuklib,
        @liblzma_api,
        @xz_inc,
    ],
    'xz/util.c' => [
        qw(
        common/mythread.h
        common/tuklib_exit.h
        common/tuklib_gettext.h
        common/tuklib_mbstr.h
        common/tuklib_progname.h
        spec_mem_io/spec_mem_io.h
        ),
        @common_tuklib,
        @liblzma_api,
        @xz_inc,
    ],
);

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
