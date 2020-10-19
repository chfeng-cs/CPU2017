$benchnum  = '502';
$benchname = 'gcc_r';
$exename   = 'cpugcc_r';  # if you change this, also edit diagnostic.c
$benchlang = 'C';
@base_exe  = ($exename);

$floatcompare = 1;
$calctol      = 0;
$nansupport   = 'no';  # No NaNs in output, so stringwise-equal is a good
                       # initial check for equality
$need_math='yes';
$bench_flags='-I. -I./include -I./spec_qsort -DSPEC_502 -DSPEC_AUTO_SUPPRESS_OPENMP';

# These were in both the Windows build batch file and mjp.cfg, so...
$bench_flags .= ' -DIN_GCC -DHAVE_CONFIG_H';

@sources = (qw(
    main.c
    cc1-checksum.c
    alias.c
    alloca.c
    alloc-pool.c
    argv.c
    attribs.c
    auto-inc-dec.c
    bb-reorder.c
    bid2dpd_dpd2bid.c
    bitmap.c
    bt-load.c
    c-lang.c
    c-errors.c
    c-lex.c
    c-pragma.c
    c-decl.c
    c-typeck.c
    c-convert.c
    c-aux-info.c
    c-common.c
    c-opts.c
    c-format.c
    c-semantics.c
    c-ppoutput.c
    c-objc-common.c
    c-dump.c
    c-parser.c
    c-gimplify.c
    c-pretty-print.c
    c-omp.c
    caller-save.c
    calls.c
    cfg.c
    cfganal.c
    cfgbuild.c
    cfgcleanup.c
    cfgexpand.c
    cfghooks.c
    cfglayout.c
    cfgloop.c
    cfgloopanal.c
    cfgloopmanip.c
    cfgrtl.c
    cgraph.c
    cgraphbuild.c
    cgraphunit.c
    combine.c
    combine-stack-adj.c
    concat.c
    convert.c
    coverage.c
    cp-demangle.c
    cp-demint.c
    cplus-dem.c
    cpp_directives.c
    cpp_lex.c
    cpp_errors.c
    cpp_expr.c
    cpp_charset.c
    cpp_macro.c
    cpp_traditional.c
    cpp_line-map.c
    cpp_symtab.c
    cpp_identifiers.c
    cpp_mkdeps.c
    cpp_pch.c
    cpp_directives-only.c
    crc32.c
    cse.c
    cselib.c
    dbxout.c
    dbgcnt.c
    dce.c
    ddg.c
    debug.c
    decContext.c
    decimal128.c
    decimal32.c
    decimal64.c
    decNumber.c
    df-byte-scan.c
    df-core.c
    df-problems.c
    df-scan.c
    dfp.c
    diagnostic.c
    dojump.c
    dominance.c
    domwalk.c
    double-int.c
    dse.c
    dwarf2asm.c
    dwarf2out.c
    dyn-string.c
    ebitmap.c
    emit-rtl.c
    et-forest.c
    except.c
    explow.c
    expmed.c
    expr.c
    fdmatch.c
    fibheap.c
    filename_cmp.c
    final.c
    fixed-value.c
    floatformat.c
    fold-const.c
    fopen_unlocked.c
    function.c
    fwprop.c
    gcse.c
    genrtl.c
    getopt1.c
    getopt.c
    getpwd.c
    getruntime.c
    ggc-common.c
    ggc-page.c
    gimple.c
    gimple-iterator.c
    gimple-low.c
    gimple-pretty-print.c
    gimplify.c
    graph.c
    graphds.c
    graphite.c
    graphite-blocking.c
    graphite-clast-to-gimple.c
    graphite-dependences.c
    graphite-interchange.c
    graphite-poly.c
    graphite-ppl.c
    graphite-scop-detection.c
    graphite-sese-to-poly.c
    gtype-desc.c
    haifa-sched.c
    hashtab.c
    hex.c
    hooks.c
    host-ieee128.c
    host-ieee32.c
    host-ieee64.c
    host-linux.c
    i386.c
    i386-c.c
    ifcvt.c
    incpath.c
    init-regs.c
    insn-attrtab.c
    insn-automata.c
    insn-emit.c
    insn-extract.c
    insn-modes.c
    insn-opinit.c
    insn-output.c
    insn-peep.c
    insn-preds.c
    insn-recog.c
    integrate.c
    ipa-cp.c
    ipa-inline.c
    ipa-prop.c
    ipa-pure-const.c
    ipa-reference.c
    ipa-struct-reorg.c
    ipa-type-escape.c
    ipa-utils.c
    ipa.c
    ira.c
    ira-build.c
    ira-costs.c
    ira-conflicts.c
    ira-color.c
    ira-emit.c
    ira-lives.c
    jump.c
    lambda-code.c
    lambda-mat.c
    lambda-trans.c
    langhooks.c
    lbasename.c
    lcm.c
    lists.c
    loop-doloop.c
    loop-init.c
    loop-invariant.c
    loop-iv.c
    loop-unroll.c
    loop-unswitch.c
    lower-subreg.c
    lrealpath.c
    lto-cgraph.c
    lto-streamer-in.c
    lto-streamer-out.c
    lto-section-in.c
    lto-section-out.c
    lto-symtab.c
    lto-opts.c
    lto-streamer.c
    lto-wpa-fixup.c
    make-relative-prefix.c
    make-temp-file.c
    partition.c
    matrix-reorg.c
    mcf.c
    md5.c
    mkstemps.c
    mode-switching.c
    modulo-sched.c
    objalloc.c
    obstack.c
    omega.c
    omp-low.c
    optabs.c
    options.c
    opts-common.c
    opts.c
    params.c
    passes.c
    physmem.c
    plugin.c
    pointer-set.c
    postreload-gcse.c
    postreload.c
    predict.c
    pretty-print.c
    print-rtl.c
    print-tree.c
    profile.c
    recog.c
    reg-stack.c
    regcprop.c
    regex.c
    reginfo.c
    regmove.c
    regrename.c
    regstat.c
    reload.c
    reload1.c
    reorg.c
    resource.c
    rtl-error.c
    rtl.c
    rtlanal.c
    rtlhooks.c
    safe-ctype.c
    sbitmap.c
    sched-deps.c
    sched-ebb.c
    sched-rgn.c
    sched-vis.c
    sdbout.c
    sel-sched-ir.c
    sel-sched-dump.c
    sel-sched.c
    sese.c
    sha1.c
    simplify-rtx.c
    sort.c
    spaces.c
    sparseset.c
    splay-tree.c
    sreal.c
    stack-ptr-mod.c
    statistics.c
    stmt.c
    stor-layout.c
    store-motion.c
    stringpool.c
    strsignal.c
    stub-objc.c
    targhooks.c
    timevar.c
    tracer.c
    tree-affine.c
    tree-call-cdce.c
    tree-cfg.c
    tree-cfgcleanup.c
    tree-chrec.c
    tree-complex.c
    tree-data-ref.c
    tree-dfa.c
    tree-dump.c
    tree-eh.c
    tree-if-conv.c
    tree-inline.c
    tree-into-ssa.c
    tree-iterator.c
    tree-loop-distribution.c
    tree-loop-linear.c
    tree-mudflap.c
    tree-nested.c
    tree-nrv.c
    tree-object-size.c
    tree-optimize.c
    tree-outof-ssa.c
    tree-parloops.c
    tree-phinodes.c
    tree-predcom.c
    tree-pretty-print.c
    tree-profile.c
    tree-scalar-evolution.c
    tree-sra.c
    tree-switch-conversion.c
    tree-ssa-address.c
    tree-ssa-alias.c
    tree-ssa-ccp.c
    tree-ssa-coalesce.c
    tree-ssa-copy.c
    tree-ssa-copyrename.c
    tree-ssa-dce.c
    tree-ssa-dom.c
    tree-ssa-dse.c
    tree-ssa-forwprop.c
    tree-ssa-ifcombine.c
    tree-ssa-live.c
    tree-ssa-loop-ch.c
    tree-ssa-loop-im.c
    tree-ssa-loop-ivcanon.c
    tree-ssa-loop-ivopts.c
    tree-ssa-loop-manip.c
    tree-ssa-loop-niter.c
    tree-ssa-loop-prefetch.c
    tree-ssa-loop-unswitch.c
    tree-ssa-loop.c
    tree-ssa-math-opts.c
    tree-ssa-operands.c
    tree-ssa-phiopt.c
    tree-ssa-phiprop.c
    tree-ssa-pre.c
    tree-ssa-propagate.c
    tree-ssa-reassoc.c
    tree-ssa-sccvn.c
    tree-ssa-sink.c
    tree-ssa-structalias.c
    tree-ssa-ter.c
    tree-ssa-threadedge.c
    tree-ssa-threadupdate.c
    tree-ssa-uncprop.c
    tree-ssa.c
    tree-ssanames.c
    tree-stdarg.c
    tree-tailcall.c
    tree-vect-generic.c
    tree-vect-patterns.c
    tree-vect-data-refs.c
    tree-vect-stmts.c
    tree-vect-loop.c
    tree-vect-loop-manip.c
    tree-vect-slp.c
    tree-vectorizer.c
    tree-vrp.c
    tree.c
    unlink-if-ordinary.c
    value-prof.c
    var-tracking.c
    varpool.c
    varasm.c
    varray.c
    vec.c
    vmsdbgout.c
    web.c
    xatexit.c
    xcoffout.c
    xexit.c
    xmalloc.c
    xmemdup.c
    xstrdup.c
    xstrerror.c
    xstrndup.c
    c-cppbuiltin.c
    c-pch.c
    cpp_files.c
    cpp_init.c
    cppdefault.c
    intl.c
    prefix.c
    strerror.c
    toplev.c
    vasprintf.c
    version.c
    builtins.c
    real.c
    mini-gmp.c
    spec_qsort/spec_qsort.c
));

use File::Basename;

sub invoke {
    my ($me) = @_;
    my $name;
    my (@rc);
    my $exe = $me->exe_file;

    my @runs = grep { !m/^\s*#/ } main::read_file('control');
    foreach my $run (@runs) {
        my ($src, @opts) = split(/\s+/, $run);
        my $out = basename($src, '.c').'.opts'.join('_', @opts);
        $out =~ s/=/_/g;
        push @rc, {
            'command' => $exe,
            'args'    => [ $src, @opts, '-o', "${out}.s" ],
            'output'  => "${out}.out",
            'error'   => "${out}.err",
        };
    }

    return @rc;
}

no strict;

# Generated with makedepend and lightly massaged into Perl
%srcdeps = (
    'main.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h
        )],

    'cc1-checksum.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h
        )],

    'alias.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tm_p.h config/i386/i386-protos.h
        tm-preds.h function.h vecprim.h emit-rtl.h regs.h
        varray.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        cfghooks.h flags.h output.h toplev.h bversion.h
        cselib.h include/splay-tree.h ggc.h gtype-desc.h
        langhooks.h timevar.h timevar.def target.h cgraph.h
        cif-code.def tree-pass.h ipa-type-escape.h df.h
        alloc-pool.h tree-ssa-alias.h pointer-set.h tree-flow.h
        gimple.h tree-ssa-operands.h gimple.def gsstruct.def
        ipa-reference.h tree-flow-inline.h gt-alias.h
        )],

    'alloca.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'alloc-pool.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h alloc-pool.h include/hashtab.h
        )],

    'argv.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/safe-ctype.h
        )],

    'attribs.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h
        toplev.h bversion.h output.h rtl.h real.h fixed-value.h
        rtl.def reg-notes.def insn-notes.def genrtl.h ggc.h
        gtype-desc.h tm_p.h config/i386/i386-protos.h
        tm-preds.h cpplib.h target.h langhooks.h plugin.h
        gcc-plugin.h highlev-plugin-common.h plugin.def
        )],

    'auto-inc-dec.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h insn-config.h regs.h
        flags.h output.h except.h toplev.h bversion.h recog.h
        expr.h emit-rtl.h timevar.h timevar.def tree-pass.h
        df.h alloc-pool.h dbgcnt.h dbgcnt.def target.h
        )],

    'bb-reorder.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h flags.h timevar.h timevar.def output.h
        cfglayout.h include/fibheap.h target.h tm_p.h
        config/i386/i386-protos.h tm-preds.h expr.h
        insn-config.h emit-rtl.h params.h params.def toplev.h
        bversion.h tree-pass.h df.h alloc-pool.h
        )],

    'bid2dpd_dpd2bid.c' => [qw(
        bid-dpd.h bid2dpd_dpd2bid.h
        )],

    'bitmap.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h include/obstack.h ggc.h gtype-desc.h
        bitmap.h include/hashtab.h gt-bitmap.h
        )],

    'bt-load.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h regs.h varray.h
        include/obstack.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h include/fibheap.h output.h
        target.h expr.h flags.h insn-config.h emit-rtl.h
        insn-attr.h insn-addr.h except.h tm_p.h
        config/i386/i386-protos.h tm-preds.h toplev.h
        bversion.h tree-pass.h timevar.h timevar.def recog.h
        df.h alloc-pool.h
        )],

    'c-lang.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h c-tree.h
        c-common.h include/splay-tree.h cpplib.h ggc.h
        gtype-desc.h toplev.h bversion.h diagnostic.h
        pretty-print.h diagnostic.def langhooks.h
        langhooks-def.h hooks.h tree-inline.h gimple.h
        pointer-set.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def
        c-objc-common.h c-pragma.h gtype-c.h
        )],

    'c-errors.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h c-tree.h
        c-common.h include/splay-tree.h cpplib.h ggc.h
        gtype-desc.h toplev.h bversion.h diagnostic.h
        pretty-print.h diagnostic.def tm_p.h
        config/i386/i386-protos.h tm-preds.h flags.h
        )],

    'c-lex.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h real.h machmode.h
        insn-modes.h mode-classes.def rtl.h statistics.h
        input.h line-map.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h output.h c-tree.h c-common.h
        include/splay-tree.h cpplib.h ggc.h gtype-desc.h
        toplev.h bversion.h diagnostic.h pretty-print.h
        diagnostic.def flags.h timevar.h timevar.def c-pragma.h
        intl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        debug.h target.h
        )],

    'c-pragma.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h function.h vecprim.h cpplib.h
        c-pragma.h flags.h toplev.h bversion.h ggc.h
        gtype-desc.h c-common.h include/splay-tree.h output.h
        tm_p.h config/i386/i386-protos.h tm-preds.h target.h
        diagnostic.h pretty-print.h diagnostic.def opts.h
        plugin.h gcc-plugin.h highlev-plugin-common.h
        plugin.def gt-c-pragma.h
        )],

    'c-decl.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h input.h line-map.h tm.h
        options.h config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h intl.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tree-inline.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h tree-ssa-operands.h
        gimple.def gsstruct.def rtl.h real.h fixed-value.h
        rtl.def reg-notes.def insn-notes.def genrtl.h flags.h
        output.h expr.h insn-config.h emit-rtl.h c-tree.h
        c-common.h include/splay-tree.h cpplib.h toplev.h
        bversion.h diagnostic.h pretty-print.h diagnostic.def
        tm_p.h config/i386/i386-protos.h tm-preds.h target.h
        debug.h opts.h timevar.h timevar.def c-pragma.h
        c-lang.h langhooks.h tree-mudflap.h tree-iterator.h
        tree-dump.h tree-pass.h cgraph.h cif-code.def
        libfuncs.h except.h langhooks-def.h hooks.h plugin.h
        gcc-plugin.h highlev-plugin-common.h plugin.def
        gt-c-decl.h
        )],

    'c-typeck.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h langhooks.h c-tree.h c-common.h
        include/splay-tree.h cpplib.h ggc.h gtype-desc.h
        toplev.h bversion.h diagnostic.h pretty-print.h
        diagnostic.def c-lang.h tm_p.h
        config/i386/i386-protos.h tm-preds.h flags.h output.h
        expr.h function.h vecprim.h insn-config.h emit-rtl.h
        intl.h target.h tree-iterator.h gimple.h pointer-set.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        cfghooks.h tree-ssa-operands.h gimple.def gsstruct.def
        tree-flow.h cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h
        )],

    'c-convert.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h
        convert.h c-common.h include/splay-tree.h cpplib.h
        ggc.h gtype-desc.h c-tree.h toplev.h bversion.h
        diagnostic.h pretty-print.h diagnostic.def langhooks.h
        target.h
        )],

    'c-aux-info.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h flags.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h c-tree.h c-common.h
        include/splay-tree.h cpplib.h ggc.h gtype-desc.h
        toplev.h bversion.h diagnostic.h pretty-print.h
        diagnostic.def
        )],

    'c-common.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h intl.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h flags.h output.h c-pragma.h cpplib.h
        rtl.h real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h ggc.h gtype-desc.h varray.h
        expr.h function.h vecprim.h insn-config.h emit-rtl.h
        c-common.h include/splay-tree.h tm_p.h
        config/i386/i386-protos.h tm-preds.h target.h
        langhooks.h tree-inline.h gimple.h pointer-set.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        include/partition.h predict.h predict.def cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def c-tree.h
        toplev.h bversion.h diagnostic.h pretty-print.h
        diagnostic.def tree-iterator.h tree-mudflap.h opts.h
        cgraph.h cif-code.def target-def.h hooks.h targhooks.h
        libfuncs.h builtin-attrs.def builtin-types.def
        gt-c-common.h
        )],

    'c-opts.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h c-common.h
        include/splay-tree.h cpplib.h ggc.h gtype-desc.h
        c-pragma.h flags.h toplev.h bversion.h langhooks.h
        tree-inline.h gimple.h pointer-set.h hard-reg-set.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h tree-ssa-operands.h gimple.def
        gsstruct.def diagnostic.h pretty-print.h diagnostic.def
        intl.h cppdefault.h incpath.h debug.h opts.h mkdeps.h
        target.h tm_p.h config/i386/i386-protos.h tm-preds.h
        c-tree.h
        )],

    'c-format.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h
        c-common.h include/splay-tree.h cpplib.h ggc.h
        gtype-desc.h toplev.h bversion.h intl.h diagnostic.h
        pretty-print.h diagnostic.def langhooks.h c-format.h
        alloc-pool.h
        )],

    'c-semantics.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h function.h
        vecprim.h include/splay-tree.h varray.h c-common.h
        cpplib.h ggc.h gtype-desc.h except.h sbitmap.h toplev.h
        bversion.h flags.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h output.h
        timevar.h timevar.def predict.h predict.def
        tree-inline.h gimple.h pointer-set.h hard-reg-set.h
        basic-block.h bitmap.h include/partition.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def
        tree-iterator.h langhooks.h
        )],

    'c-ppoutput.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        tree.h include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h c-common.h
        include/splay-tree.h ggc.h gtype-desc.h c-pragma.h
        )],

    'c-objc-common.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h insn-config.h integrate.h varray.h c-tree.h
        c-common.h include/splay-tree.h cpplib.h ggc.h
        gtype-desc.h toplev.h bversion.h diagnostic.h
        pretty-print.h diagnostic.def intl.h c-pretty-print.h
        function.h vecprim.h flags.h tree-inline.h gimple.h
        pointer-set.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        cfghooks.h tree-ssa-operands.h gimple.def gsstruct.def
        langhooks.h tree-mudflap.h target.h c-objc-common.h
        )],

    'c-dump.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h c-tree.h
        c-common.h include/splay-tree.h cpplib.h ggc.h
        gtype-desc.h toplev.h bversion.h diagnostic.h
        pretty-print.h diagnostic.def tree-dump.h tree-pass.h
        timevar.h timevar.def
        )],

    'c-parser.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h langhooks.h cpplib.h timevar.h timevar.def
        c-pragma.h c-tree.h c-common.h include/splay-tree.h
        ggc.h gtype-desc.h toplev.h bversion.h diagnostic.h
        pretty-print.h diagnostic.def flags.h output.h target.h
        cgraph.h basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        cif-code.def plugin.h gcc-plugin.h
        highlev-plugin-common.h plugin.def except.h
        gt-c-parser.h
        )],

    'c-gimplify.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h varray.h
        c-tree.h c-common.h include/splay-tree.h cpplib.h ggc.h
        gtype-desc.h toplev.h bversion.h diagnostic.h
        pretty-print.h diagnostic.def gimple.h pointer-set.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h tree-ssa-operands.h gimple.def
        gsstruct.def tree-flow.h cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-inline.h langhooks.h langhooks-def.h hooks.h
        flags.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tree-dump.h
        tree-pass.h timevar.h timevar.def c-pretty-print.h
        )],

    'c-pretty-print.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h real.h machmode.h
        insn-modes.h mode-classes.def fixed-value.h
        double-int.h mini-gmp.h intl.h c-pretty-print.h tree.h
        include/hashtab.h input.h line-map.h statistics.h vec.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h c-common.h
        include/splay-tree.h cpplib.h ggc.h gtype-desc.h
        pretty-print.h c-tree.h toplev.h bversion.h
        diagnostic.h diagnostic.def tree-iterator.h
        )],

    'c-omp.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h function.h
        vecprim.h c-common.h include/splay-tree.h cpplib.h
        ggc.h gtype-desc.h toplev.h bversion.h gimple.h
        pointer-set.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def cfghooks.h tree-ssa-operands.h gimple.def
        gsstruct.def langhooks.h
        )],

    'caller-save.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h insn-config.h flags.h recog.h reload.h
        expr.h emit-rtl.h toplev.h bversion.h tm_p.h
        config/i386/i386-protos.h tm-preds.h addresses.h
        output.h df.h alloc-pool.h timevar.h timevar.def ggc.h
        gtype-desc.h gt-caller-save.h
        )],

    'calls.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h gimple.h pointer-set.h ggc.h
        gtype-desc.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def flags.h
        expr.h insn-config.h emit-rtl.h optabs.h insn-codes.h
        libfuncs.h regs.h toplev.h bversion.h output.h tm_p.h
        config/i386/i386-protos.h tm-preds.h timevar.h
        timevar.def langhooks.h target.h debug.h cgraph.h
        cif-code.def except.h dbgcnt.h dbgcnt.def tree-flow.h
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        )],

    'cfg.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h regs.h varray.h basic-block.h
        bitmap.h sbitmap.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h flags.h
        output.h except.h toplev.h bversion.h tm_p.h
        config/i386/i386-protos.h tm-preds.h timevar.h
        timevar.def tree-pass.h ggc.h gtype-desc.h alloc-pool.h
        df.h cfgloop.h tree-flow.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h
        )],

    'cfganal.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h include/obstack.h hard-reg-set.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h
        insn-config.h recog.h toplev.h bversion.h tm_p.h
        config/i386/i386-protos.h tm-preds.h timevar.h
        timevar.def
        )],

    'cfgbuild.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h regs.h
        flags.h output.h except.h expr.h insn-config.h
        emit-rtl.h toplev.h bversion.h timevar.h timevar.def
        )],

    'cfgcleanup.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h regs.h varray.h
        include/obstack.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h timevar.h timevar.def output.h
        insn-config.h flags.h recog.h toplev.h bversion.h
        cselib.h params.h params.def tm_p.h
        config/i386/i386-protos.h tm-preds.h target.h
        cfglayout.h emit-rtl.h tree-pass.h cfgloop.h expr.h
        df.h alloc-pool.h dce.h dbgcnt.h dbgcnt.def
        )],

    'cfgexpand.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h expr.h
        flags.h insn-config.h emit-rtl.h langhooks.h
        tree-flow.h gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h timevar.h timevar.def tree-dump.h
        include/splay-tree.h tree-pass.h except.h diagnostic.h
        pretty-print.h diagnostic.def toplev.h bversion.h
        debug.h params.h params.def tree-inline.h value-prof.h
        target.h ssaexpand.h tree-ssa-live.h
        )],

    'cfghooks.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h tree-flow.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h timevar.h timevar.def toplev.h
        bversion.h cfgloop.h
        )],

    'cfglayout.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        insn-config.h output.h cfglayout.h cfgloop.h target.h
        ggc.h gtype-desc.h alloc-pool.h flags.h tree-pass.h
        timevar.h timevar.def df.h gt-cfglayout.h
        )],

    'cfgloop.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h include/obstack.h function.h
        tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h predict.h predict.def cfghooks.h
        toplev.h bversion.h cfgloop.h flags.h tree-flow.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h output.h
        )],

    'cfgloopanal.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h cfgloop.h
        expr.h flags.h insn-config.h emit-rtl.h output.h
        graphds.h params.h params.def
        )],

    'cfgloopmanip.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h cfgloop.h
        cfglayout.h output.h tree-flow.h gimple.h pointer-set.h
        ggc.h gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h
        )],

    'cfgrtl.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h regs.h
        flags.h output.h except.h toplev.h bversion.h tm_p.h
        config/i386/i386-protos.h tm-preds.h insn-attr.h
        insn-addr.h insn-config.h cfglayout.h expr.h emit-rtl.h
        target.h cfgloop.h ggc.h gtype-desc.h tree-pass.h
        timevar.h timevar.def df.h alloc-pool.h
        )],

    'cgraph.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tree-inline.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h tree-ssa-operands.h
        gimple.def gsstruct.def langhooks.h toplev.h bversion.h
        flags.h debug.h target.h cgraph.h cif-code.def output.h
        intl.h tree-dump.h include/splay-tree.h tree-pass.h
        timevar.h timevar.def tree-flow.h ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h value-prof.h
        except.h diagnostic.h pretty-print.h diagnostic.def
        rtl.h real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h gt-cgraph.h
        )],

    'cgraphbuild.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tree-flow.h
        bitmap.h hard-reg-set.h basic-block.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h gimple.h pointer-set.h
        ggc.h gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h langhooks.h intl.h
        tree-pass.h timevar.h timevar.def
        )],

    'cgraphunit.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-inline.h langhooks.h toplev.h
        bversion.h flags.h debug.h target.h diagnostic.h
        pretty-print.h diagnostic.def timevar.h timevar.def
        params.h params.def include/fibheap.h intl.h ipa-prop.h
        tree-iterator.h tree-pass.h tree-dump.h
        include/splay-tree.h output.h coverage.h gcov-io.h
        gcov-iov.h plugin.h gcc-plugin.h
        highlev-plugin-common.h plugin.def gt-cgraphunit.h
        )],

    'combine.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tm_p.h config/i386/i386-protos.h
        tm-preds.h flags.h regs.h varray.h hard-reg-set.h
        basic-block.h bitmap.h sbitmap.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        insn-config.h expr.h emit-rtl.h insn-attr.h insn-addr.h
        recog.h toplev.h bversion.h target.h optabs.h
        insn-codes.h rtlhooks-def.h output.h params.h
        params.def timevar.h timevar.def tree-pass.h df.h
        alloc-pool.h cgraph.h cif-code.def
        )],

    'combine-stack-adj.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        insn-config.h recog.h output.h regs.h varray.h
        include/obstack.h hard-reg-set.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h flags.h expr.h emit-rtl.h df.h
        alloc-pool.h timevar.h timevar.def except.h toplev.h
        bversion.h reload.h tree-pass.h
        )],

    'concat.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'convert.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h
        convert.h toplev.h bversion.h langhooks.h real.h
        fixed-value.h
        )],

    'coverage.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h flags.h output.h regs.h varray.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h expr.h insn-config.h emit-rtl.h
        toplev.h bversion.h tm_p.h config/i386/i386-protos.h
        tm-preds.h ggc.h gtype-desc.h coverage.h gcov-io.h
        gcov-iov.h langhooks.h tree-iterator.h cgraph.h
        cif-code.def tree-pass.h timevar.h timevar.def
        gcov-io.c gt-coverage.h
        )],

    'cp-demangle.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/demangle.h cp-demangle.h
        )],

    'cp-demint.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/demangle.h cp-demangle.h
        )],

    'cplus-dem.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/safe-ctype.h include/demangle.h
        include/libiberty.h
        )],

    'cpp_directives.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        mkdeps.h
        )],

    'cpp_lex.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        )],

    'cpp_errors.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        )],

    'cpp_expr.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        )],

    'cpp_charset.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        ucnid.h
        )],

    'cpp_macro.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        )],

    'cpp_traditional.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        )],

    'cpp_line-map.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h line-map.h
        )],

    'cpp_symtab.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h symtab.h include/obstack.h
        )],

    'cpp_identifiers.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        )],

    'cpp_mkdeps.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h mkdeps.h
        )],

    'cpp_pch.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        include/hashtab.h mkdeps.h
        )],

    'cpp_directives-only.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        )],

    'crc32.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'cse.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h regs.h varray.h include/obstack.h
        basic-block.h bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h recog.h expr.h emit-rtl.h toplev.h
        bversion.h output.h ggc.h gtype-desc.h timevar.h
        timevar.def except.h target.h params.h params.def
        rtlhooks-def.h tree-pass.h df.h alloc-pool.h dbgcnt.h
        dbgcnt.def
        )],

    'cselib.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        regs.h varray.h include/obstack.h hard-reg-set.h
        basic-block.h bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h recog.h emit-rtl.h toplev.h bversion.h
        output.h ggc.h gtype-desc.h tree-pass.h timevar.h
        timevar.def cselib.h params.h params.def alloc-pool.h
        target.h gt-cselib.h
        )],

    'dbxout.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h regs.h varray.h hard-reg-set.h
        basic-block.h bitmap.h sbitmap.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        insn-config.h reload.h output.h dbxout.h toplev.h
        bversion.h tm_p.h config/i386/i386-protos.h tm-preds.h
        ggc.h gtype-desc.h debug.h target.h langhooks.h expr.h
        emit-rtl.h gstab.h stab.def gt-dbxout.h
        )],

    'dbgcnt.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h errors.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h output.h dbgcnt.h dbgcnt.def
        )],

    'dce.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h include/hashtab.h tm.h
        options.h config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        regs.h varray.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h flags.h except.h df.h
        alloc-pool.h timevar.h timevar.def cselib.h dce.h
        tree-pass.h dbgcnt.h dbgcnt.def tm_p.h
        config/i386/i386-protos.h tm-preds.h
        )],

    'ddg.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        regs.h varray.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h insn-attr.h insn-addr.h except.h recog.h
        sched-int.h df.h alloc-pool.h timevar.h timevar.def
        target.h cfglayout.h cfgloop.h expr.h emit-rtl.h ddg.h
        )],

    'debug.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h debug.h
        )],

    'decContext.c' => [qw(
        dconfig.h config.h auto-host.h include/ansidecl.h
        decContext.h gstdint.h decContextSymbols.h
        decNumberLocal.h decDPDSymbols.h decCommonSymbols.h
        )],

    'decimal128.c' => [qw(
        dconfig.h config.h auto-host.h include/ansidecl.h
        decNumber.h decContext.h gstdint.h decContextSymbols.h
        decNumberSymbols.h decNumberLocal.h decDPDSymbols.h
        decCommonSymbols.h decimal128.h decimal128Local.h
        decimal128Symbols.h bid-dpd.h
        )],

    'decimal32.c' => [qw(
        dconfig.h config.h auto-host.h include/ansidecl.h
        decNumber.h decContext.h gstdint.h decContextSymbols.h
        decNumberSymbols.h decNumberLocal.h decDPDSymbols.h
        decCommonSymbols.h decimal32.h decimal32Symbols.h
        bid-dpd.h
        )],

    'decimal64.c' => [qw(
        dconfig.h config.h auto-host.h include/ansidecl.h
        decNumber.h decContext.h gstdint.h decContextSymbols.h
        decNumberSymbols.h decNumberLocal.h decDPDSymbols.h
        decCommonSymbols.h decimal64.h decimal64Symbols.h
        decDPD.h bid-dpd.h
        )],

    'decNumber.c' => [qw(
        dconfig.h config.h auto-host.h include/ansidecl.h
        decNumber.h decContext.h gstdint.h decContextSymbols.h
        decNumberSymbols.h decNumberLocal.h decDPDSymbols.h
        decCommonSymbols.h
        )],

    'df-byte-scan.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        df.h bitmap.h include/hashtab.h include/obstack.h
        basic-block.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h tree.h
        all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h alloc-pool.h
        timevar.h timevar.def output.h dbgcnt.h dbgcnt.def
        )],

    'df-core.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        insn-config.h recog.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        vecprim.h regs.h varray.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h include/partition.h predict.h
        predict.def cfghooks.h output.h alloc-pool.h flags.h
        timevar.h timevar.def df.h tree-pass.h params.h
        params.def
        )],

    'df-problems.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        insn-config.h recog.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        vecprim.h regs.h varray.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h include/partition.h predict.h
        predict.def cfghooks.h output.h alloc-pool.h flags.h
        timevar.h timevar.def df.h except.h dce.h
        )],

    'df-scan.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        insn-config.h recog.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        vecprim.h regs.h varray.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h include/partition.h predict.h
        predict.def cfghooks.h output.h alloc-pool.h flags.h
        timevar.h timevar.def target.h target-def.h hooks.h
        targhooks.h df.h tree-pass.h
        )],

    'dfp.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h toplev.h
        bversion.h real.h tm_p.h config/i386/i386-protos.h
        tm-preds.h dfp.h decimal128.h decimal128Local.h
        decimal128Symbols.h decimal64.h decimal64Symbols.h
        decimal32.h decimal32Symbols.h decNumber.h decContext.h
        gstdint.h decContextSymbols.h decNumberSymbols.h
        )],

    'diagnostic.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h version.h
        tm_p.h config/i386/i386-protos.h tm-preds.h flags.h
        toplev.h bversion.h intl.h diagnostic.h pretty-print.h
        diagnostic.def langhooks.h langhooks-def.h hooks.h
        opts.h plugin.h gcc-plugin.h highlev-plugin-common.h
        plugin.def
        )],

    'dojump.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h flags.h function.h vecprim.h
        insn-config.h insn-attr.h insn-addr.h expr.h emit-rtl.h
        optabs.h insn-codes.h langhooks.h ggc.h gtype-desc.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def cfghooks.h output.h gt-dojump.h
        )],

    'dominance.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h toplev.h
        bversion.h et-forest.h timevar.h timevar.def
        pointer-set.h graphds.h
        )],

    'domwalk.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h basic-block.h bitmap.h
        include/hashtab.h statistics.h include/obstack.h
        sbitmap.h varray.h include/partition.h hard-reg-set.h
        predict.h predict.def vec.h function.h tree.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h double-int.h mini-gmp.h alias.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h domwalk.h ggc.h gtype-desc.h
        )],

    'double-int.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h
        )],

    'dse.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h include/hashtab.h tm.h
        options.h config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        tm_p.h config/i386/i386-protos.h tm-preds.h regs.h
        varray.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h flags.h df.h
        alloc-pool.h timevar.h timevar.def cselib.h tree-pass.h
        insn-config.h expr.h emit-rtl.h recog.h dse.h optabs.h
        insn-codes.h dbgcnt.h dbgcnt.def target.h
        )],

    'dwarf2asm.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h flags.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h output.h target.h
        dwarf2asm.h include/dwarf2.h include/splay-tree.h ggc.h
        gtype-desc.h tm_p.h config/i386/i386-protos.h
        tm-preds.h gt-dwarf2asm.h
        )],

    'dwarf2out.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h version.h
        flags.h real.h rtl.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h hard-reg-set.h
        regs.h varray.h basic-block.h bitmap.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h insn-config.h reload.h output.h
        expr.h emit-rtl.h libfuncs.h except.h include/dwarf2.h
        dwarf2out.h dwarf2asm.h toplev.h bversion.h ggc.h
        gtype-desc.h md5.h tm_p.h config/i386/i386-protos.h
        tm-preds.h diagnostic.h pretty-print.h diagnostic.def
        debug.h target.h langhooks.h cgraph.h cif-code.def
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def tree-pass.h timevar.h timevar.def
        gt-dwarf2out.h
        )],

    'dyn-string.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/dyn-string.h
        )],

    'ebitmap.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h include/obstack.h ebitmap.h sbitmap.h
        )],

    'emit-rtl.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        tm_p.h config/i386/i386-protos.h tm-preds.h flags.h
        function.h vecprim.h expr.h insn-config.h emit-rtl.h
        regs.h varray.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        cfghooks.h recog.h ggc.h gtype-desc.h debug.h
        langhooks.h tree-pass.h timevar.h timevar.def df.h
        alloc-pool.h params.h params.def target.h gt-emit-rtl.h
        )],

    'et-forest.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h et-forest.h alloc-pool.h
        )],

    'except.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h flags.h function.h vecprim.h expr.h
        insn-config.h emit-rtl.h libfuncs.h except.h sbitmap.h
        integrate.h varray.h hard-reg-set.h basic-block.h
        bitmap.h include/partition.h predict.h predict.def
        cfghooks.h output.h dwarf2asm.h dwarf2out.h
        include/dwarf2.h toplev.h bversion.h intl.h ggc.h
        gtype-desc.h tm_p.h config/i386/i386-protos.h
        tm-preds.h target.h langhooks.h cgraph.h cif-code.def
        diagnostic.h pretty-print.h diagnostic.def tree-pass.h
        timevar.h timevar.def tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h gt-except.h
        )],

    'explow.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        tm_p.h config/i386/i386-protos.h tm-preds.h flags.h
        except.h sbitmap.h vecprim.h function.h expr.h
        insn-config.h emit-rtl.h optabs.h insn-codes.h
        hard-reg-set.h ggc.h gtype-desc.h recog.h langhooks.h
        target.h output.h gt-explow.h
        )],

    'expmed.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        tm_p.h config/i386/i386-protos.h tm-preds.h flags.h
        insn-config.h expr.h function.h vecprim.h emit-rtl.h
        optabs.h insn-codes.h recog.h langhooks.h df.h bitmap.h
        basic-block.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def cfghooks.h
        alloc-pool.h timevar.h timevar.def target.h
        )],

    'expr.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h machmode.h insn-modes.h
        mode-classes.def real.h rtl.h statistics.h input.h
        line-map.h vec.h fixed-value.h double-int.h mini-gmp.h
        alias.h rtl.def reg-notes.def insn-notes.def genrtl.h
        tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h flags.h regs.h varray.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h except.h insn-config.h insn-attr.h
        insn-addr.h expr.h emit-rtl.h optabs.h insn-codes.h
        libfuncs.h recog.h reload.h output.h typeclass.h
        toplev.h bversion.h ggc.h gtype-desc.h langhooks.h
        intl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        tree-iterator.h tree-pass.h timevar.h timevar.def
        tree-flow.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        target.h df.h alloc-pool.h diagnostic.h pretty-print.h
        diagnostic.def ssaexpand.h tree-ssa-live.h gt-expr.h
        )],

    'fdmatch.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'fibheap.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/fibheap.h
        )],

    'filename_cmp.c' => [qw(
        config.h auto-host.h include/ansidecl.h filenames.h
        include/safe-ctype.h
        )],

    'final.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        regs.h varray.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h insn-config.h
        insn-attr.h insn-addr.h recog.h conditions.h flags.h
        output.h except.h toplev.h bversion.h reload.h intl.h
        target.h debug.h expr.h emit-rtl.h cfglayout.h
        tree-pass.h timevar.h timevar.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        coverage.h gcov-io.h gcov-iov.h df.h alloc-pool.h
        cfgloop.h params.h params.def dwarf2out.h dbxout.h
        )],

    'fixed-value.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h toplev.h
        bversion.h fixed-value.h real.h
        )],

    'floatformat.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/floatformat.h
        )],

    'fold-const.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h flags.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h real.h fixed-value.h rtl.h rtl.def
        reg-notes.def insn-notes.def genrtl.h expr.h function.h
        vecprim.h insn-config.h emit-rtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h target.h toplev.h
        bversion.h intl.h ggc.h gtype-desc.h langhooks.h md5.h
        gimple.h pointer-set.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def cfghooks.h tree-ssa-operands.h
        gimple.def gsstruct.def
        )],

    'fopen_unlocked.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'function.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h flags.h except.h sbitmap.h vecprim.h
        function.h expr.h insn-config.h emit-rtl.h optabs.h
        insn-codes.h libfuncs.h regs.h varray.h hard-reg-set.h
        basic-block.h bitmap.h include/partition.h predict.h
        predict.def cfghooks.h recog.h output.h toplev.h
        bversion.h ggc.h gtype-desc.h tm_p.h
        config/i386/i386-protos.h tm-preds.h integrate.h
        langhooks.h target.h cfglayout.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def tree-pass.h
        timevar.h timevar.def df.h alloc-pool.h gt-function.h
        )],

    'fwprop.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h timevar.h timevar.def rtl.h
        statistics.h machmode.h insn-modes.h mode-classes.def
        real.h vec.h fixed-value.h double-int.h mini-gmp.h alias.h
        rtl.def reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h emit-rtl.h
        insn-config.h recog.h flags.h include/obstack.h
        basic-block.h bitmap.h include/hashtab.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h tree.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h output.h df.h alloc-pool.h
        target.h cfgloop.h tree-pass.h domwalk.h
        )],

    'gcse.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        tm_p.h config/i386/i386-protos.h tm-preds.h regs.h
        varray.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h flags.h insn-config.h
        recog.h output.h expr.h emit-rtl.h except.h ggc.h
        gtype-desc.h params.h params.def cselib.h intl.h
        timevar.h timevar.def tree-pass.h df.h alloc-pool.h
        dbgcnt.h dbgcnt.def target.h gt-gcse.h
        )],

    'genrtl.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h include/obstack.h rtl.h
        statistics.h machmode.h insn-modes.h mode-classes.def
        input.h line-map.h real.h vec.h fixed-value.h
        double-int.h mini-gmp.h alias.h rtl.def reg-notes.def
        insn-notes.def genrtl.h ggc.h gtype-desc.h
        )],

    'getopt1.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/getopt.h
        )],

    'getopt.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/getopt.h
        )],

    'getpwd.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'getruntime.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'ggc-common.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h include/hashtab.h ggc.h
        statistics.h gtype-desc.h toplev.h input.h line-map.h
        bversion.h params.h params.def hosthooks.h
        hosthooks-def.h hooks.h machmode.h insn-modes.h
        mode-classes.def plugin.h gcc-plugin.h
        highlev-plugin-common.h plugin.def vec.h
        )],

    'ggc-page.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        toplev.h bversion.h flags.h ggc.h gtype-desc.h
        timevar.h timevar.def params.h params.def tree-flow.h
        bitmap.h hard-reg-set.h basic-block.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h cfgloop.h plugin.h gcc-plugin.h
        highlev-plugin-common.h plugin.def
        )],

    'gimple.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h target.h insn-modes.h
        tree.h include/hashtab.h machmode.h mode-classes.def
        input.h line-map.h statistics.h vec.h double-int.h
        mini-gmp.h alias.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        ggc.h gtype-desc.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def toplev.h bversion.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h value-prof.h flags.h
        include/demangle.h gt-gimple.h
        )],

    'gimple-iterator.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h gimple.h
        pointer-set.h ggc.h gtype-desc.h hard-reg-set.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h tree-ssa-operands.h gimple.def
        gsstruct.def tree-flow.h cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        value-prof.h
        )],

    'gimple-low.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h varray.h gimple.h pointer-set.h ggc.h
        gtype-desc.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h tree-ssa-operands.h
        gimple.def gsstruct.def tree-iterator.h tree-inline.h
        diagnostic.h pretty-print.h diagnostic.def langhooks.h
        langhooks-def.h hooks.h tree-flow.h cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h timevar.h timevar.def except.h
        flags.h expr.h insn-config.h emit-rtl.h toplev.h
        bversion.h tree-pass.h
        )],

    'gimple-pretty-print.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h diagnostic.h
        pretty-print.h diagnostic.def real.h tree-flow.h
        bitmap.h hard-reg-set.h basic-block.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h gimple.h pointer-set.h
        ggc.h gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-pass.h
        timevar.h timevar.def value-prof.h
        )],

    'gimplify.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h varray.h gimple.h pointer-set.h ggc.h
        gtype-desc.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h tree-ssa-operands.h
        gimple.def gsstruct.def tree-iterator.h tree-inline.h
        diagnostic.h pretty-print.h diagnostic.def langhooks.h
        langhooks-def.h hooks.h tree-flow.h cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h timevar.h timevar.def except.h
        flags.h output.h expr.h insn-config.h emit-rtl.h
        toplev.h bversion.h target.h optabs.h insn-codes.h
        include/splay-tree.h tree-pass.h gt-gimplify.h
        )],

    'graph.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h output.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        vecprim.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def cfghooks.h toplev.h bversion.h graph.h
        )],

    'graphds.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h include/obstack.h
        bitmap.h include/hashtab.h statistics.h vec.h vecprim.h
        graphds.h
        )],

    'graphite.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h toplev.h bversion.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h tree-chrec.h tree-data-ref.h graphds.h
        lambda.h omega.h params.h params.def
        tree-scalar-evolution.h value-prof.h sese.h
        )],

    'graphite-blocking.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h output.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h toplev.h bversion.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h tree-chrec.h tree-data-ref.h
        graphds.h lambda.h omega.h params.h params.def
        tree-scalar-evolution.h domwalk.h value-prof.h
        )],

    'graphite-clast-to-gimple.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h toplev.h bversion.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h tree-chrec.h tree-data-ref.h graphds.h
        lambda.h omega.h params.h params.def
        tree-scalar-evolution.h domwalk.h value-prof.h sese.h
        )],

    'graphite-dependences.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h toplev.h bversion.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h tree-chrec.h tree-data-ref.h graphds.h
        lambda.h omega.h params.h params.def
        tree-scalar-evolution.h domwalk.h
        )],

    'graphite-interchange.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h output.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h toplev.h bversion.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h tree-chrec.h tree-data-ref.h
        graphds.h lambda.h omega.h params.h params.def
        tree-scalar-evolution.h domwalk.h value-prof.h
        )],

    'graphite-poly.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h output.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h toplev.h bversion.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h tree-chrec.h tree-data-ref.h
        graphds.h lambda.h omega.h params.h params.def
        tree-scalar-evolution.h domwalk.h value-prof.h
        )],

    'graphite-ppl.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h
        )],

    'graphite-scop-detection.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h toplev.h bversion.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h tree-chrec.h tree-data-ref.h graphds.h
        lambda.h omega.h params.h params.def
        tree-scalar-evolution.h domwalk.h value-prof.h sese.h
        )],

    'graphite-sese-to-poly.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h toplev.h bversion.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h tree-chrec.h tree-data-ref.h graphds.h
        lambda.h omega.h params.h params.def
        tree-scalar-evolution.h domwalk.h value-prof.h sese.h
        )],

    'gtype-desc.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h varray.h
        include/hashtab.h include/splay-tree.h
        include/obstack.h bitmap.h statistics.h input.h
        line-map.h tree.h machmode.h insn-modes.h
        mode-classes.def vec.h double-int.h mini-gmp.h alias.h
        all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h rtl.h real.h fixed-value.h
        rtl.def reg-notes.def insn-notes.def genrtl.h
        function.h vecprim.h insn-config.h expr.h flags.h
        emit-rtl.h hard-reg-set.h basic-block.h sbitmap.h
        include/partition.h predict.h predict.def cfghooks.h
        cselib.h insn-addr.h optabs.h insn-codes.h libfuncs.h
        debug.h ggc.h gtype-desc.h cgraph.h cif-code.def
        tree-flow.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h reload.h
        cpp-id-data.h cpplib.h tree-chrec.h cfglayout.h
        except.h output.h cfgloop.h target.h ipa-prop.h
        )],

    'haifa-sched.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        regs.h varray.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h insn-attr.h insn-addr.h except.h recog.h
        sched-int.h df.h alloc-pool.h timevar.h timevar.def
        target.h output.h params.h params.def dbgcnt.h
        dbgcnt.def cfgloop.h ira.h
        )],

    'hashtab.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/hashtab.h
        )],

    'hex.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/safe-ctype.h
        )],

    'hooks.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h hooks.h machmode.h
        insn-modes.h mode-classes.def
        )],

    'host-ieee128.c' => [qw(
        dconfig.h config.h auto-host.h include/ansidecl.h
        bid-dpd.h decimal128.h decimal128Local.h
        decimal128Symbols.h
        )],

    'host-ieee32.c' => [qw(
        bid-dpd.h decimal32.h decimal32Symbols.h
        )],

    'host-ieee64.c' => [qw(
        bid-dpd.h decimal64.h decimal64Symbols.h
        )],

    'host-linux.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h hosthooks.h
        hosthooks-def.h hooks.h machmode.h insn-modes.h
        mode-classes.def
        )],

    'i386.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tm_p.h config/i386/i386-protos.h
        tm-preds.h regs.h varray.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        insn-config.h conditions.h output.h insn-codes.h
        insn-attr.h insn-addr.h flags.h except.h recog.h expr.h
        emit-rtl.h optabs.h toplev.h bversion.h ggc.h
        gtype-desc.h target.h target-def.h hooks.h targhooks.h
        langhooks.h cgraph.h cif-code.def gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def include/dwarf2.h df.h alloc-pool.h
        timevar.h timevar.def tm-constrs.h params.h params.def
        cselib.h debug.h dwarf2out.h i386-builtin-types.inc
        gt-i386.h
        )],

    'i386-c.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tm_p.h config/i386/i386-protos.h
        tm-preds.h flags.h c-common.h include/splay-tree.h
        cpplib.h ggc.h gtype-desc.h target.h target-def.h
        hooks.h targhooks.h c-pragma.h
        )],

    'ifcvt.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h flags.h insn-config.h recog.h except.h
        expr.h emit-rtl.h output.h optabs.h insn-codes.h
        toplev.h bversion.h tm_p.h config/i386/i386-protos.h
        tm-preds.h cfgloop.h target.h timevar.h timevar.def
        tree-pass.h df.h alloc-pool.h dbgcnt.h dbgcnt.def
        )],

    'incpath.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h machmode.h insn-modes.h
        mode-classes.def target.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h cpplib.h symtab.h
        include/obstack.h line-map.h prefix.h intl.h incpath.h
        cppdefault.h
        )],

    'init-regs.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h regs.h varray.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h expr.h
        flags.h insn-config.h emit-rtl.h tree-pass.h timevar.h
        timevar.def df.h alloc-pool.h
        )],

    'insn-attrtab.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h insn-attr.h insn-addr.h vecprim.h tm_p.h
        config/i386/i386-protos.h tm-preds.h insn-config.h
        recog.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h cfghooks.h
        output.h toplev.h bversion.h flags.h
        )],

    'insn-automata.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        insn-config.h recog.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h output.h insn-attr.h insn-addr.h toplev.h
        bversion.h flags.h
        )],

    'insn-emit.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        function.h tree.h include/hashtab.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h vecprim.h expr.h flags.h
        insn-config.h emit-rtl.h optabs.h insn-codes.h dfp.h
        output.h hard-reg-set.h recog.h resource.h df.h
        bitmap.h basic-block.h sbitmap.h varray.h
        include/partition.h predict.h predict.def cfghooks.h
        alloc-pool.h timevar.h timevar.def reload.h toplev.h
        bversion.h regs.h tm-constrs.h ggc.h gtype-desc.h
        integrate.h
        )],

    'insn-extract.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h insn-config.h recog.h toplev.h bversion.h
        )],

    'insn-modes.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h machmode.h insn-modes.h
        mode-classes.def real.h
        )],

    'insn-opinit.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        flags.h insn-config.h recog.h expr.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        vecprim.h emit-rtl.h optabs.h insn-codes.h reload.h
        )],

    'insn-output.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h flags.h ggc.h
        statistics.h gtype-desc.h rtl.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h expr.h function.h
        tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h vecprim.h insn-config.h emit-rtl.h
        insn-codes.h tm_p.h config/i386/i386-protos.h
        tm-preds.h regs.h varray.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h include/partition.h predict.h
        predict.def cfghooks.h conditions.h insn-attr.h
        insn-addr.h recog.h toplev.h bversion.h output.h
        target.h tm-constrs.h
        )],

    'insn-peep.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h insn-config.h rtl.h
        statistics.h machmode.h insn-modes.h mode-classes.def
        input.h line-map.h real.h vec.h fixed-value.h
        double-int.h mini-gmp.h alias.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h regs.h varray.h
        include/obstack.h hard-reg-set.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h output.h recog.h except.h toplev.h
        bversion.h flags.h tm-constrs.h
        )],

    'insn-preds.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tm_p.h config/i386/i386-protos.h
        tm-preds.h function.h vecprim.h insn-config.h recog.h
        output.h flags.h hard-reg-set.h resource.h df.h
        bitmap.h basic-block.h sbitmap.h varray.h
        include/partition.h predict.h predict.def cfghooks.h
        alloc-pool.h timevar.h timevar.def toplev.h bversion.h
        reload.h regs.h tm-constrs.h
        )],

    'insn-recog.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        function.h tree.h include/hashtab.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h vecprim.h insn-config.h recog.h
        output.h flags.h hard-reg-set.h resource.h df.h
        bitmap.h basic-block.h sbitmap.h varray.h
        include/partition.h predict.h predict.def cfghooks.h
        alloc-pool.h timevar.h timevar.def toplev.h bversion.h
        reload.h regs.h tm-constrs.h
        )],

    'integrate.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tm_p.h config/i386/i386-protos.h
        tm-preds.h regs.h varray.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h flags.h
        debug.h insn-config.h expr.h emit-rtl.h output.h
        recog.h integrate.h except.h toplev.h bversion.h intl.h
        params.h params.def ggc.h gtype-desc.h target.h
        langhooks.h tree-pass.h timevar.h timevar.def df.h
        alloc-pool.h gt-integrate.h
        )],

    'ipa-cp.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h options.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h target.h tm.h config/vxworks-dummy.h
        config/i386/i386.h config/i386/unix.h config/i386/att.h
        config/dbxelf.h config/elfos.h config/svr4.h
        config/linux.h config/glibc-stdint.h
        config/i386/linux.h defaults.h insn-constants.h
        insn-flags.h cgraph.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        cif-code.def ipa-prop.h tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-pass.h
        timevar.h timevar.def flags.h diagnostic.h
        pretty-print.h diagnostic.def tree-dump.h
        include/splay-tree.h tree-inline.h include/fibheap.h
        params.h params.def
        )],

    'ipa-inline.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tree-inline.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h tree-ssa-operands.h
        gimple.def gsstruct.def langhooks.h flags.h cgraph.h
        cif-code.def diagnostic.h pretty-print.h diagnostic.def
        timevar.h timevar.def params.h params.def
        include/fibheap.h intl.h tree-pass.h coverage.h
        gcov-io.h gcov-iov.h tree-flow.h ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h ipa-prop.h except.h gt-ipa-inline.h
        )],

    'ipa-prop.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h options.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h langhooks.h ggc.h gtype-desc.h
        target.h tm.h config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h cgraph.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h cif-code.def ipa-prop.h
        tree-flow.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-pass.h
        timevar.h timevar.def tree-inline.h flags.h
        diagnostic.h pretty-print.h diagnostic.def
        lto-streamer.h include/plugin-api.h
        )],

    'ipa-pure-const.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tree-flow.h
        bitmap.h hard-reg-set.h basic-block.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h gimple.h pointer-set.h
        ggc.h gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-inline.h
        tree-pass.h timevar.h timevar.def langhooks.h
        ipa-utils.h output.h flags.h diagnostic.h
        pretty-print.h diagnostic.def target.h lto-streamer.h
        include/plugin-api.h cfgloop.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree-scalar-evolution.h
        )],

    'ipa-reference.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tree-flow.h
        bitmap.h hard-reg-set.h basic-block.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h gimple.h pointer-set.h
        ggc.h gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-inline.h
        tree-pass.h timevar.h timevar.def langhooks.h
        include/splay-tree.h ipa-utils.h output.h flags.h
        diagnostic.h pretty-print.h diagnostic.def
        lto-streamer.h include/plugin-api.h target.h
        gt-ipa-reference.h
        )],

    'ipa-struct-reorg.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h gimple.h
        pointer-set.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def
        tree-inline.h tree-flow.h cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        langhooks.h toplev.h bversion.h flags.h debug.h
        target.h diagnostic.h pretty-print.h diagnostic.def
        timevar.h timevar.def params.h params.def
        include/fibheap.h intl.h tree-iterator.h tree-pass.h
        ipa-struct-reorg.h opts.h ipa-type-escape.h tree-dump.h
        include/splay-tree.h
        )],

    'ipa-type-escape.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tree-flow.h
        bitmap.h hard-reg-set.h basic-block.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h gimple.h pointer-set.h
        ggc.h gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-inline.h
        tree-pass.h timevar.h timevar.def langhooks.h
        include/splay-tree.h ipa-utils.h ipa-type-escape.h
        output.h flags.h diagnostic.h pretty-print.h
        diagnostic.def
        )],

    'ipa-utils.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tree-flow.h
        bitmap.h hard-reg-set.h basic-block.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h gimple.h pointer-set.h
        ggc.h gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-inline.h
        tree-pass.h timevar.h timevar.def langhooks.h
        include/splay-tree.h ipa-utils.h output.h flags.h
        diagnostic.h pretty-print.h diagnostic.def
        )],

    'ipa.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h cgraph.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        cif-code.def tree-pass.h timevar.h timevar.def gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def
        )],

    'ira.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h regs.h varray.h
        include/obstack.h hard-reg-set.h basic-block.h bitmap.h
        include/hashtab.h statistics.h sbitmap.h
        include/partition.h predict.h predict.def vec.h
        function.h tree.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        target.h flags.h expr.h insn-config.h emit-rtl.h
        recog.h params.h params.def timevar.h timevar.def
        tree-pass.h output.h except.h reload.h errors.h
        integrate.h df.h alloc-pool.h ggc.h gtype-desc.h
        ira-int.h cfgloop.h ira.h
        )],

    'ira-build.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        target.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h flags.h insn-config.h recog.h toplev.h
        bversion.h params.h params.def df.h alloc-pool.h
        timevar.h timevar.def output.h reload.h sparseset.h
        ira-int.h cfgloop.h ira.h
        )],

    'ira-costs.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h hard-reg-set.h rtl.h
        statistics.h machmode.h insn-modes.h mode-classes.def
        input.h line-map.h real.h vec.h fixed-value.h
        double-int.h mini-gmp.h alias.h rtl.def reg-notes.def
        insn-notes.def genrtl.h expr.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        vecprim.h flags.h insn-config.h emit-rtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def cfghooks.h regs.h addresses.h
        recog.h toplev.h bversion.h target.h params.h
        params.def ira-int.h cfgloop.h ira.h alloc-pool.h
        )],

    'ira-conflicts.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h regs.h varray.h
        include/obstack.h hard-reg-set.h basic-block.h bitmap.h
        include/hashtab.h statistics.h sbitmap.h
        include/partition.h predict.h predict.def vec.h
        function.h tree.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        target.h flags.h insn-config.h recog.h toplev.h
        bversion.h params.h params.def df.h alloc-pool.h
        timevar.h timevar.def sparseset.h ira-int.h cfgloop.h
        ira.h addresses.h
        )],

    'ira-color.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        target.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h flags.h expr.h insn-config.h emit-rtl.h
        toplev.h bversion.h reload.h params.h params.def df.h
        alloc-pool.h timevar.h timevar.def include/splay-tree.h
        ira-int.h cfgloop.h ira.h
        )],

    'ira-emit.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h regs.h varray.h
        include/obstack.h hard-reg-set.h basic-block.h bitmap.h
        include/hashtab.h statistics.h sbitmap.h
        include/partition.h predict.h predict.def vec.h
        function.h tree.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        target.h flags.h expr.h insn-config.h emit-rtl.h
        recog.h params.h params.def timevar.h timevar.def
        tree-pass.h output.h reload.h errors.h df.h
        alloc-pool.h ira-int.h cfgloop.h ira.h
        )],

    'ira-lives.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h regs.h varray.h
        include/obstack.h hard-reg-set.h basic-block.h bitmap.h
        include/hashtab.h statistics.h sbitmap.h
        include/partition.h predict.h predict.def vec.h
        function.h tree.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        target.h flags.h except.h insn-config.h recog.h
        toplev.h bversion.h params.h params.def df.h
        alloc-pool.h timevar.h timevar.def sparseset.h
        ira-int.h cfgloop.h ira.h
        )],

    'jump.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        flags.h hard-reg-set.h regs.h varray.h
        include/obstack.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h insn-config.h insn-attr.h
        insn-addr.h recog.h expr.h emit-rtl.h except.h
        diagnostic.h pretty-print.h diagnostic.def toplev.h
        bversion.h reload.h timevar.h timevar.def tree-pass.h
        target.h
        )],

    'lambda-code.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h target.h rtl.h real.h fixed-value.h
        rtl.def reg-notes.def insn-notes.def genrtl.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h expr.h flags.h insn-config.h emit-rtl.h
        optabs.h insn-codes.h tree-chrec.h tree-data-ref.h
        graphds.h lambda.h omega.h params.h params.def
        tree-scalar-evolution.h
        )],

    'lambda-mat.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h lambda.h
        )],

    'lambda-trans.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h target.h tree-flow.h bitmap.h
        hard-reg-set.h basic-block.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h lambda.h
        )],

    'langhooks.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h intl.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tree-inline.h gimple.h pointer-set.h
        ggc.h gtype-desc.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h insn-config.h integrate.h
        flags.h langhooks.h target.h langhooks-def.h hooks.h
        diagnostic.h pretty-print.h diagnostic.def cgraph.h
        cif-code.def output.h
        )],

    'lbasename.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/safe-ctype.h filenames.h
        )],

    'lcm.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h flags.h insn-config.h recog.h output.h
        tm_p.h config/i386/i386-protos.h tm-preds.h insn-attr.h
        insn-addr.h
        )],

    'lists.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h ggc.h
        gtype-desc.h gt-lists.h
        )],

    'loop-doloop.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h expr.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        vecprim.h insn-config.h emit-rtl.h hard-reg-set.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h predict.h predict.def cfghooks.h
        toplev.h bversion.h tm_p.h config/i386/i386-protos.h
        tm-preds.h cfgloop.h output.h params.h params.def
        target.h
        )],

    'loop-init.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h cfgloop.h
        cfglayout.h tree-pass.h timevar.h timevar.def flags.h
        df.h alloc-pool.h ggc.h gtype-desc.h
        )],

    'loop-invariant.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h hard-reg-set.h rtl.h
        statistics.h machmode.h insn-modes.h mode-classes.def
        input.h line-map.h real.h vec.h fixed-value.h
        double-int.h mini-gmp.h alias.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h include/obstack.h
        basic-block.h bitmap.h include/hashtab.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h cfgloop.h expr.h flags.h insn-config.h
        emit-rtl.h recog.h output.h df.h alloc-pool.h timevar.h
        timevar.def except.h params.h params.def regs.h ira.h
        )],

    'loop-iv.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h cfgloop.h
        expr.h flags.h insn-config.h emit-rtl.h intl.h output.h
        toplev.h bversion.h df.h alloc-pool.h timevar.h
        timevar.def
        )],

    'loop-unroll.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h cfgloop.h
        cfglayout.h params.h params.def output.h expr.h flags.h
        insn-config.h emit-rtl.h recog.h
        )],

    'loop-unswitch.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h cfgloop.h
        cfglayout.h params.h params.def output.h expr.h flags.h
        insn-config.h emit-rtl.h
        )],

    'lower-subreg.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h machmode.h insn-modes.h
        mode-classes.def tm.h options.h config/vxworks-dummy.h
        config/i386/i386.h config/i386/unix.h config/i386/att.h
        config/dbxelf.h config/elfos.h config/svr4.h
        config/linux.h config/glibc-stdint.h
        config/i386/linux.h defaults.h insn-constants.h
        insn-flags.h rtl.h statistics.h input.h line-map.h
        real.h vec.h fixed-value.h double-int.h mini-gmp.h alias.h
        rtl.def reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h timevar.h
        timevar.def flags.h insn-config.h include/obstack.h
        basic-block.h bitmap.h include/hashtab.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h tree.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h recog.h expr.h emit-rtl.h except.h
        regs.h tree-pass.h df.h alloc-pool.h
        )],

    'lrealpath.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'lto-cgraph.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h expr.h function.h vecprim.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h flags.h insn-config.h
        emit-rtl.h params.h params.def varray.h langhooks.h
        basic-block.h bitmap.h sbitmap.h include/partition.h
        hard-reg-set.h predict.h predict.def cfghooks.h
        tree-flow.h gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h diagnostic.h pretty-print.h
        diagnostic.def except.h timevar.h timevar.def output.h
        lto-streamer.h include/plugin-api.h target.h gcov-io.h
        gcov-iov.h
        )],

    'lto-streamer-in.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h expr.h function.h vecprim.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h flags.h insn-config.h
        emit-rtl.h params.h params.def varray.h basic-block.h
        bitmap.h sbitmap.h include/partition.h hard-reg-set.h
        predict.h predict.def cfghooks.h tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-pass.h timevar.h timevar.def diagnostic.h
        pretty-print.h diagnostic.def libfuncs.h except.h
        debug.h output.h ipa-utils.h lto-streamer.h
        include/plugin-api.h target.h
        )],

    'lto-streamer-out.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h expr.h function.h vecprim.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h flags.h insn-config.h
        emit-rtl.h params.h params.def varray.h basic-block.h
        bitmap.h sbitmap.h include/partition.h hard-reg-set.h
        predict.h predict.def cfghooks.h tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-pass.h timevar.h timevar.def diagnostic.h
        pretty-print.h diagnostic.def except.h
        include/lto-symtab.h lto-streamer.h
        include/plugin-api.h target.h
        )],

    'lto-section-in.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h expr.h function.h vecprim.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h flags.h insn-config.h
        emit-rtl.h params.h params.def varray.h basic-block.h
        bitmap.h sbitmap.h include/partition.h hard-reg-set.h
        predict.h predict.def cfghooks.h tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        diagnostic.h pretty-print.h diagnostic.def except.h
        timevar.h timevar.def output.h lto-streamer.h
        include/plugin-api.h target.h lto-compress.h
        )],

    'lto-section-out.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h expr.h function.h vecprim.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h flags.h insn-config.h
        emit-rtl.h params.h params.def varray.h basic-block.h
        bitmap.h sbitmap.h include/partition.h hard-reg-set.h
        predict.h predict.def cfghooks.h tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-pass.h timevar.h timevar.def except.h langhooks.h
        lto-streamer.h include/plugin-api.h target.h
        lto-compress.h
        )],

    'lto-symtab.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h toplev.h input.h
        line-map.h bversion.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h options.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h gimple.h pointer-set.h ggc.h
        gtype-desc.h tm.h config/vxworks-dummy.h
        config/i386/i386.h config/i386/unix.h config/i386/att.h
        config/dbxelf.h config/elfos.h config/svr4.h
        config/linux.h config/glibc-stdint.h
        config/i386/linux.h defaults.h insn-constants.h
        insn-flags.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def lambda.h
        include/plugin-api.h lto-streamer.h target.h cgraph.h
        cif-code.def gt-lto-symtab.h
        )],

    'lto-opts.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h options.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h ggc.h gtype-desc.h bitmap.h flags.h
        opts.h target.h tm.h config/vxworks-dummy.h
        config/i386/i386.h config/i386/unix.h config/i386/att.h
        config/dbxelf.h config/elfos.h config/svr4.h
        config/linux.h config/glibc-stdint.h
        config/i386/linux.h defaults.h insn-constants.h
        insn-flags.h toplev.h bversion.h lto-streamer.h
        include/plugin-api.h gimple.h pointer-set.h
        hard-reg-set.h basic-block.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def
        )],

    'lto-streamer.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h gimple.h pointer-set.h ggc.h
        gtype-desc.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def tree-flow.h
        cgraph.h cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h diagnostic.h pretty-print.h
        diagnostic.def lto-streamer.h include/plugin-api.h
        target.h
        )],

    'lto-wpa-fixup.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h expr.h function.h vecprim.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h flags.h insn-config.h
        emit-rtl.h cgraph.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def cfghooks.h cif-code.def diagnostic.h
        pretty-print.h diagnostic.def timevar.h timevar.def
        tree-flow.h gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-pass.h lto-streamer.h include/plugin-api.h
        target.h
        )],

    'make-relative-prefix.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'make-temp-file.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'partition.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/partition.h
        )],

    'matrix-reorg.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree-inline.h gimple.h pointer-set.h ggc.h
        gtype-desc.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def tree-flow.h
        cgraph.h cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h langhooks.h toplev.h bversion.h
        flags.h debug.h target.h diagnostic.h pretty-print.h
        diagnostic.def timevar.h timevar.def params.h
        params.def include/fibheap.h intl.h cfgloop.h
        tree-iterator.h tree-pass.h opts.h tree-data-ref.h
        graphds.h lambda.h omega.h tree-chrec.h
        tree-scalar-evolution.h tree-ssa-sccvn.h
        )],

    'mcf.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h basic-block.h bitmap.h
        include/hashtab.h statistics.h include/obstack.h
        sbitmap.h varray.h include/partition.h hard-reg-set.h
        predict.h predict.def vec.h function.h tree.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h double-int.h mini-gmp.h alias.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h output.h langhooks.h gcov-io.h
        gcov-iov.h profile.h
        )],

    'md5.c' => [qw(
        config.h auto-host.h include/ansidecl.h md5.h
        )],

    'mkstemps.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        )],

    'mode-switching.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h flags.h insn-config.h recog.h output.h
        tm_p.h config/i386/i386-protos.h tm-preds.h tree-pass.h
        timevar.h timevar.def df.h alloc-pool.h insn-attr.h
        insn-addr.h
        )],

    'modulo-sched.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        regs.h varray.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h insn-attr.h insn-addr.h except.h recog.h
        sched-int.h df.h alloc-pool.h timevar.h timevar.def
        target.h cfglayout.h cfgloop.h expr.h emit-rtl.h
        params.h params.def gcov-io.h gcov-iov.h ddg.h
        tree-pass.h dbgcnt.h dbgcnt.def
        )],

    'objalloc.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/objalloc.h
        )],

    'obstack.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/obstack.h
        )],

    'omega.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h diagnostic.h pretty-print.h
        diagnostic.def varray.h tree-pass.h timevar.h
        timevar.def omega.h params.h params.def
        )],

    'omp-low.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h gimple.h pointer-set.h ggc.h gtype-desc.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h tree-ssa-operands.h
        gimple.def gsstruct.def tree-iterator.h tree-inline.h
        langhooks.h diagnostic.h pretty-print.h diagnostic.def
        tree-flow.h cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h timevar.h
        timevar.def flags.h expr.h insn-config.h emit-rtl.h
        toplev.h bversion.h tree-pass.h except.h
        include/splay-tree.h optabs.h insn-codes.h cfgloop.h
        gt-omp-low.h
        )],

    'optabs.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h insn-config.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        tm_p.h config/i386/i386-protos.h tm-preds.h flags.h
        function.h vecprim.h except.h sbitmap.h expr.h
        emit-rtl.h optabs.h insn-codes.h libfuncs.h recog.h
        reload.h ggc.h gtype-desc.h basic-block.h bitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def cfghooks.h target.h gt-optabs.h
        )],

    'options.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h opts.h intl.h flags.h
        target.h insn-modes.h
        )],

    'opts-common.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h intl.h coretypes.h opts.h
        )],

    'opts.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h intl.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h expr.h function.h vecprim.h flags.h
        insn-config.h emit-rtl.h ggc.h gtype-desc.h output.h
        langhooks.h opts.h toplev.h bversion.h params.h
        params.def diagnostic.h pretty-print.h diagnostic.def
        tm_p.h config/i386/i386-protos.h tm-preds.h insn-attr.h
        insn-addr.h target.h tree-pass.h timevar.h timevar.def
        dbgcnt.h dbgcnt.def debug.h plugin.h gcc-plugin.h
        highlev-plugin-common.h plugin.def except.h sbitmap.h
        lto-streamer.h include/plugin-api.h gimple.h
        pointer-set.h hard-reg-set.h basic-block.h bitmap.h
        varray.h include/partition.h predict.h predict.def
        cfghooks.h tree-ssa-operands.h gimple.def gsstruct.def
        cgraph.h cif-code.def
        )],

    'params.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h params.h params.def
        toplev.h input.h line-map.h bversion.h
        )],

    'passes.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h line-map.h input.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        flags.h insn-attr.h insn-addr.h vecprim.h insn-config.h
        hard-reg-set.h recog.h output.h except.h sbitmap.h
        function.h toplev.h bversion.h expr.h emit-rtl.h
        basic-block.h bitmap.h varray.h include/partition.h
        predict.h predict.def cfghooks.h intl.h ggc.h
        gtype-desc.h graph.h regs.h timevar.h timevar.def
        diagnostic.h pretty-print.h diagnostic.def params.h
        params.def reload.h dwarf2asm.h integrate.h debug.h
        target.h langhooks.h cfglayout.h cfgloop.h hosthooks.h
        cgraph.h cif-code.def opts.h coverage.h gcov-io.h
        gcov-iov.h value-prof.h tree-inline.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def tree-flow.h ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-pass.h
        tree-dump.h include/splay-tree.h df.h alloc-pool.h
        lto-streamer.h include/plugin-api.h plugin.h
        gcc-plugin.h highlev-plugin-common.h plugin.def
        dwarf2out.h dbxout.h gt-passes.h
        )],

    'physmem.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'plugin.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h toplev.h input.h
        line-map.h bversion.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h options.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tree-pass.h timevar.h timevar.def
        intl.h plugin.h gcc-plugin.h highlev-plugin-common.h
        plugin.def ggc.h gtype-desc.h
        )],

    'pointer-set.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h pointer-set.h
        )],

    'postreload-gcse.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        tm_p.h config/i386/i386-protos.h tm-preds.h regs.h
        varray.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h flags.h insn-config.h
        recog.h output.h expr.h emit-rtl.h except.h intl.h
        params.h params.def target.h timevar.h timevar.def
        tree-pass.h dbgcnt.h dbgcnt.def
        )],

    'postreload.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h machmode.h insn-modes.h
        mode-classes.def hard-reg-set.h rtl.h statistics.h
        input.h line-map.h real.h vec.h fixed-value.h
        double-int.h mini-gmp.h alias.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h include/obstack.h
        insn-config.h flags.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h expr.h
        emit-rtl.h optabs.h insn-codes.h regs.h varray.h
        basic-block.h bitmap.h sbitmap.h include/partition.h
        predict.h predict.def cfghooks.h reload.h recog.h
        output.h cselib.h toplev.h bversion.h except.h
        timevar.h timevar.def tree-pass.h df.h alloc-pool.h
        dbgcnt.h dbgcnt.def
        )],

    'predict.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h insn-config.h regs.h
        flags.h output.h except.h toplev.h bversion.h recog.h
        expr.h emit-rtl.h coverage.h gcov-io.h gcov-iov.h
        sreal.h params.h params.def target.h cfgloop.h
        tree-flow.h gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def
        tree-scalar-evolution.h
        )],

    'pretty-print.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h intl.h pretty-print.h
        include/obstack.h input.h line-map.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def statistics.h vec.h double-int.h mini-gmp.h
        alias.h options.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h ggc.h gtype-desc.h
        )],

    'print-rtl.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h flags.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def cselib.h
        tree-pass.h timevar.h timevar.def
        )],

    'print-tree.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h real.h
        fixed-value.h ggc.h gtype-desc.h langhooks.h
        tree-iterator.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-pass.h
        timevar.h timevar.def
        )],

    'profile.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h output.h regs.h varray.h
        include/obstack.h hard-reg-set.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h expr.h insn-config.h emit-rtl.h
        toplev.h bversion.h coverage.h gcov-io.h gcov-iov.h
        value-prof.h tree-flow.h gimple.h pointer-set.h ggc.h
        gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h timevar.h
        timevar.def cfgloop.h tree-pass.h profile.h
        )],

    'recog.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        insn-config.h insn-attr.h insn-addr.h vecprim.h
        hard-reg-set.h recog.h regs.h varray.h
        include/obstack.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        cfghooks.h addresses.h expr.h flags.h emit-rtl.h
        toplev.h bversion.h output.h reload.h target.h
        timevar.h timevar.def tree-pass.h df.h alloc-pool.h
        )],

    'reg-stack.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        function.h vecprim.h insn-config.h regs.h varray.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        include/partition.h predict.h predict.def cfghooks.h
        flags.h toplev.h bversion.h recog.h output.h
        cfglayout.h reload.h ggc.h gtype-desc.h timevar.h
        timevar.def tree-pass.h target.h df.h alloc-pool.h
        )],

    'regcprop.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        insn-config.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h addresses.h reload.h output.h recog.h
        flags.h toplev.h bversion.h timevar.h timevar.def
        tree-pass.h df.h alloc-pool.h
        )],

    'regex.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/xregex.h include/xregex2.h
        )],

    'reginfo.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h hard-reg-set.h rtl.h
        statistics.h machmode.h insn-modes.h mode-classes.def
        input.h line-map.h real.h vec.h fixed-value.h
        double-int.h mini-gmp.h alias.h rtl.def reg-notes.def
        insn-notes.def genrtl.h expr.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        vecprim.h flags.h insn-config.h emit-rtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def cfghooks.h regs.h addresses.h
        recog.h reload.h toplev.h bversion.h output.h ggc.h
        gtype-desc.h timevar.h timevar.def target.h tree-pass.h
        df.h alloc-pool.h ira.h gt-reginfo.h
        )],

    'regmove.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        insn-config.h recog.h output.h regs.h varray.h
        include/obstack.h hard-reg-set.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h flags.h expr.h emit-rtl.h except.h
        toplev.h bversion.h reload.h timevar.h timevar.def
        tree-pass.h df.h alloc-pool.h ira.h
        )],

    'regrename.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        insn-config.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h addresses.h reload.h output.h recog.h
        flags.h toplev.h bversion.h timevar.h timevar.def
        tree-pass.h df.h alloc-pool.h
        )],

    'regstat.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        flags.h regs.h varray.h include/obstack.h
        hard-reg-set.h basic-block.h bitmap.h include/hashtab.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h output.h except.h timevar.h timevar.def df.h
        alloc-pool.h
        )],

    'reload.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        insn-config.h expr.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        vecprim.h flags.h emit-rtl.h optabs.h insn-codes.h
        recog.h reload.h regs.h varray.h hard-reg-set.h
        basic-block.h bitmap.h sbitmap.h include/partition.h
        predict.h predict.def cfghooks.h addresses.h output.h
        toplev.h bversion.h params.h params.def target.h df.h
        alloc-pool.h timevar.h timevar.def ira.h
        )],

    'reload1.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h machmode.h insn-modes.h
        mode-classes.def hard-reg-set.h rtl.h statistics.h
        input.h line-map.h real.h vec.h fixed-value.h
        double-int.h mini-gmp.h alias.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h include/obstack.h
        insn-config.h flags.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h expr.h
        emit-rtl.h optabs.h insn-codes.h regs.h varray.h
        basic-block.h bitmap.h sbitmap.h include/partition.h
        predict.h predict.def cfghooks.h addresses.h reload.h
        recog.h output.h toplev.h bversion.h except.h ira.h
        df.h alloc-pool.h timevar.h timevar.def target.h
        )],

    'reorg.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h expr.h function.h
        tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h vecprim.h flags.h insn-config.h
        emit-rtl.h conditions.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def cfghooks.h regs.h recog.h
        output.h insn-attr.h insn-addr.h resource.h df.h
        alloc-pool.h timevar.h timevar.def except.h params.h
        params.def target.h tree-pass.h
        )],

    'resource.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        function.h tree.h include/hashtab.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h vecprim.h regs.h varray.h
        basic-block.h bitmap.h sbitmap.h include/partition.h
        predict.h predict.def cfghooks.h flags.h output.h
        resource.h df.h alloc-pool.h timevar.h timevar.def
        except.h insn-attr.h insn-addr.h params.h params.def
        )],

    'rtl-error.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h insn-attr.h insn-addr.h vecprim.h
        insn-config.h toplev.h bversion.h intl.h diagnostic.h
        pretty-print.h include/obstack.h diagnostic.def
        )],

    'rtl.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h ggc.h gtype-desc.h toplev.h bversion.h
        )],

    'rtlanal.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h hard-reg-set.h
        insn-config.h recog.h target.h output.h tm_p.h
        config/i386/i386-protos.h tm-preds.h flags.h regs.h
        varray.h include/obstack.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h df.h alloc-pool.h timevar.h
        timevar.def
        )],

    'rtlhooks.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h rtlhooks-def.h expr.h function.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        vecprim.h flags.h insn-config.h emit-rtl.h recog.h
        )],

    'safe-ctype.c' => [qw(
        include/ansidecl.h include/safe-ctype.h
        )],

    'sbitmap.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h hard-reg-set.h include/obstack.h
        basic-block.h bitmap.h include/hashtab.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h tree.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h vecprim.h
        cfghooks.h
        )],

    'sched-deps.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        regs.h varray.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h insn-attr.h insn-addr.h except.h recog.h
        sched-int.h df.h alloc-pool.h timevar.h timevar.def
        params.h params.def cselib.h ira.h target.h
        )],

    'sched-ebb.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        regs.h varray.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h insn-attr.h insn-addr.h except.h recog.h
        cfglayout.h params.h params.def sched-int.h df.h
        alloc-pool.h timevar.h timevar.def target.h output.h
        )],

    'sched-rgn.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        regs.h varray.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h insn-attr.h insn-addr.h except.h recog.h
        cfglayout.h params.h params.def sched-int.h df.h
        alloc-pool.h timevar.h timevar.def sel-sched.h target.h
        tree-pass.h dbgcnt.h dbgcnt.def
        )],

    'sched-vis.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h include/obstack.h hard-reg-set.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h insn-attr.h
        insn-addr.h sched-int.h df.h alloc-pool.h timevar.h
        timevar.def tree-pass.h
        )],

    'sdbout.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h debug.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h ggc.h gtype-desc.h varray.h
        gt-sdbout.h
        )],

    'sel-sched-ir.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        regs.h varray.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h insn-attr.h insn-addr.h except.h recog.h
        params.h params.def target.h timevar.h timevar.def
        tree-pass.h sched-int.h df.h alloc-pool.h ggc.h
        gtype-desc.h langhooks.h rtlhooks-def.h sel-sched-ir.h
        cfgloop.h sel-sched-dump.h
        )],

    'sel-sched-dump.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        regs.h varray.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h insn-attr.h insn-addr.h params.h
        params.def output.h cselib.h target.h sel-sched-ir.h
        ggc.h gtype-desc.h sched-int.h df.h alloc-pool.h
        timevar.h timevar.def cfgloop.h sel-sched-dump.h
        )],

    'sel-sched.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        regs.h varray.h include/obstack.h basic-block.h
        bitmap.h include/hashtab.h sbitmap.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h flags.h
        insn-config.h insn-attr.h insn-addr.h except.h recog.h
        params.h params.def target.h output.h timevar.h
        timevar.def tree-pass.h sched-int.h df.h alloc-pool.h
        ggc.h gtype-desc.h langhooks.h rtlhooks-def.h
        sel-sched-ir.h cfgloop.h sel-sched-dump.h sel-sched.h
        dbgcnt.h dbgcnt.def
        )],

    'sese.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h toplev.h bversion.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h tree-chrec.h tree-data-ref.h graphds.h
        lambda.h omega.h params.h params.def
        tree-scalar-evolution.h domwalk.h value-prof.h sese.h
        )],

    'sha1.c' => [qw(
        config.h auto-host.h include/ansidecl.h include/sha1.h
        )],

    'simplify-rtx.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tm_p.h config/i386/i386-protos.h
        tm-preds.h regs.h varray.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h flags.h
        insn-config.h recog.h expr.h emit-rtl.h toplev.h
        bversion.h output.h ggc.h gtype-desc.h target.h
        )],

    'sort.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/sort.h
        )],

    'spaces.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'sparseset.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h sparseset.h
        )],

    'splay-tree.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h include/splay-tree.h
        )],

    'sreal.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h sreal.h
        )],

    'stack-ptr-mod.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h regs.h varray.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h expr.h
        flags.h insn-config.h emit-rtl.h tree-pass.h timevar.h
        timevar.def output.h df.h alloc-pool.h
        )],

    'statistics.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tree-pass.h timevar.h
        timevar.def tree-dump.h include/splay-tree.h
        statistics.h include/hashtab.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h function.h tree.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h vec.h double-int.h mini-gmp.h alias.h
        all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h vecprim.h
        )],

    'stmt.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h tree.h include/hashtab.h
        all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tm_p.h
        config/i386/i386-protos.h tm-preds.h flags.h except.h
        sbitmap.h vecprim.h function.h insn-config.h expr.h
        emit-rtl.h libfuncs.h recog.h toplev.h bversion.h
        output.h ggc.h gtype-desc.h langhooks.h predict.h
        predict.def optabs.h insn-codes.h target.h gimple.h
        pointer-set.h basic-block.h bitmap.h varray.h
        include/partition.h cfghooks.h tree-ssa-operands.h
        gimple.def gsstruct.def regs.h alloc-pool.h
        pretty-print.h
        )],

    'stor-layout.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        flags.h function.h vecprim.h expr.h insn-config.h
        emit-rtl.h output.h toplev.h bversion.h ggc.h
        gtype-desc.h target.h langhooks.h regs.h varray.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        include/partition.h predict.h predict.def cfghooks.h
        params.h params.def cgraph.h cif-code.def tree-inline.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def gt-stor-layout.h
        )],

    'store-motion.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        tm_p.h config/i386/i386-protos.h tm-preds.h regs.h
        varray.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h flags.h insn-config.h
        recog.h output.h expr.h emit-rtl.h except.h ggc.h
        gtype-desc.h intl.h timevar.h timevar.def tree-pass.h
        df.h alloc-pool.h dbgcnt.h dbgcnt.def
        )],

    'stringpool.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h cpplib.h gt-stringpool.h
        )],

    'strsignal.c' => [qw(
        libib_config.h include/ansidecl.h include/libiberty.h
        )],

    'stub-objc.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h options.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h c-common.h include/splay-tree.h
        cpplib.h ggc.h gtype-desc.h
        )],

    'targhooks.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h machmode.h insn-modes.h
        mode-classes.def rtl.h statistics.h input.h line-map.h
        real.h vec.h fixed-value.h double-int.h mini-gmp.h alias.h
        rtl.def reg-notes.def insn-notes.def genrtl.h tree.h
        include/hashtab.h all-tree.def tree.def c-common.def
        builtins.def sync-builtins.def omp-builtins.def
        treestruct.def tree-check.h symtab.h include/obstack.h
        expr.h function.h vecprim.h flags.h insn-config.h
        emit-rtl.h output.h toplev.h bversion.h target.h tm_p.h
        config/i386/i386-protos.h tm-preds.h target-def.h
        hooks.h targhooks.h ggc.h gtype-desc.h hard-reg-set.h
        reload.h optabs.h insn-codes.h recog.h gt-targhooks.h
        )],

    'timevar.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h intl.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h toplev.h bversion.h flags.h timevar.h
        timevar.def
        )],

    'tracer.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h output.h
        cfglayout.h include/fibheap.h flags.h timevar.h
        timevar.def params.h params.def coverage.h gcov-io.h
        gcov-iov.h tree-pass.h tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-inline.h
        )],

    'tree-affine.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h output.h diagnostic.h pretty-print.h
        diagnostic.def tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def pointer-set.h
        tree-affine.h gimple.h ggc.h gtype-desc.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def flags.h
        )],

    'tree-call-cdce.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h rtl.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        include/obstack.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        flags.h
        )],

    'tree-cfg.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h flags.h expr.h
        insn-config.h emit-rtl.h ggc.h gtype-desc.h langhooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h timevar.h
        timevar.def tree-dump.h include/splay-tree.h
        tree-pass.h toplev.h bversion.h except.h cfgloop.h
        cfglayout.h tree-ssa-propagate.h value-prof.h
        tree-inline.h
        )],

    'tree-cfgcleanup.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h toplev.h
        bversion.h flags.h expr.h insn-config.h emit-rtl.h
        ggc.h gtype-desc.h langhooks.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h timevar.h
        timevar.def tree-dump.h include/splay-tree.h
        tree-pass.h except.h cfgloop.h cfglayout.h
        tree-ssa-propagate.h tree-scalar-evolution.h
        )],

    'tree-chrec.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h real.h diagnostic.h pretty-print.h
        diagnostic.def cfgloop.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h hard-reg-set.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        rtl.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-chrec.h
        tree-pass.h timevar.h timevar.def params.h params.def
        flags.h tree-scalar-evolution.h
        )],

    'tree-complex.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-iterator.h tree-pass.h
        timevar.h timevar.def tree-ssa-propagate.h diagnostic.h
        pretty-print.h diagnostic.def
        )],

    'tree-data-ref.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h vec.h double-int.h mini-gmp.h alias.h
        all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h tree-data-ref.h graphds.h lambda.h omega.h
        params.h params.def tree-chrec.h
        tree-scalar-evolution.h langhooks.h
        )],

    'tree-dfa.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h include/hashtab.h
        pointer-set.h tree.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h output.h timevar.h timevar.def
        expr.h flags.h insn-config.h emit-rtl.h ggc.h
        gtype-desc.h langhooks.h diagnostic.h pretty-print.h
        diagnostic.def tree-dump.h include/splay-tree.h
        tree-pass.h gimple.h tree-ssa-operands.h gimple.def
        gsstruct.def tree-flow.h cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-inline.h convert.h params.h params.def
        )],

    'tree-dump.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h
        include/splay-tree.h diagnostic.h pretty-print.h
        diagnostic.def toplev.h bversion.h tree-dump.h
        tree-pass.h timevar.h timevar.def langhooks.h
        tree-iterator.h real.h fixed-value.h
        )],

    'tree-eh.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        flags.h function.h vecprim.h except.h sbitmap.h
        pointer-set.h tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h varray.h include/partition.h predict.h
        predict.def cfghooks.h gimple.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def tree-inline.h
        tree-iterator.h langhooks.h toplev.h bversion.h
        target.h
        )],

    'tree-if-conv.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h
        timevar.h timevar.def varray.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h basic-block.h bitmap.h sbitmap.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-dump.h include/splay-tree.h
        tree-pass.h cfgloop.h tree-chrec.h tree-data-ref.h
        graphds.h lambda.h omega.h params.h params.def
        tree-scalar-evolution.h target.h
        )],

    'tree-inline.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def statistics.h
        vec.h double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tree-inline.h gimple.h pointer-set.h
        ggc.h gtype-desc.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h expr.h flags.h insn-config.h
        emit-rtl.h params.h params.def langhooks.h
        tree-iterator.h cgraph.h cif-code.def intl.h
        tree-mudflap.h tree-flow.h ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h diagnostic.h
        pretty-print.h diagnostic.def except.h debug.h
        ipa-prop.h value-prof.h tree-pass.h timevar.h
        timevar.def target.h integrate.h
        )],

    'tree-into-ssa.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h langhooks.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h expr.h
        insn-config.h emit-rtl.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h gimple.h pointer-set.h ggc.h
        gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-inline.h
        timevar.h timevar.def tree-dump.h include/splay-tree.h
        tree-pass.h cfgloop.h domwalk.h params.h params.def
        )],

    'tree-iterator.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h options.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h gimple.h pointer-set.h ggc.h
        gtype-desc.h tm.h config/vxworks-dummy.h
        config/i386/i386.h config/i386/unix.h config/i386/att.h
        config/dbxelf.h config/elfos.h config/svr4.h
        config/linux.h config/glibc-stdint.h
        config/i386/linux.h defaults.h insn-constants.h
        insn-flags.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def
        tree-iterator.h gt-tree-iterator.h
        )],

    'tree-loop-distribution.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h target.h rtl.h real.h fixed-value.h
        rtl.def reg-notes.def insn-notes.def genrtl.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h expr.h flags.h insn-config.h emit-rtl.h
        optabs.h insn-codes.h tree-chrec.h tree-data-ref.h
        graphds.h lambda.h omega.h params.h params.def
        tree-scalar-evolution.h langhooks.h tree-vectorizer.h
        )],

    'tree-loop-linear.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h target.h rtl.h real.h fixed-value.h
        rtl.def reg-notes.def insn-notes.def genrtl.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h expr.h flags.h insn-config.h emit-rtl.h
        optabs.h insn-codes.h tree-chrec.h tree-data-ref.h
        graphds.h lambda.h omega.h params.h params.def
        tree-scalar-evolution.h
        )],

    'tree-mudflap.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h hard-reg-set.h rtl.h
        statistics.h machmode.h insn-modes.h mode-classes.def
        input.h line-map.h real.h vec.h fixed-value.h
        double-int.h mini-gmp.h alias.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tree.h include/hashtab.h
        all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tm_p.h
        config/i386/i386-protos.h tm-preds.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        flags.h tree-inline.h gimple.h pointer-set.h ggc.h
        gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def tree-iterator.h tree-flow.h cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-mudflap.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        diagnostic.h pretty-print.h diagnostic.def
        include/demangle.h langhooks.h toplev.h bversion.h
        gt-tree-mudflap.h
        )],

    'tree-nested.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        function.h vecprim.h tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def tree-inline.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        cfghooks.h tree-ssa-operands.h gimple.def gsstruct.def
        tree-iterator.h tree-flow.h cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        expr.h flags.h insn-config.h emit-rtl.h langhooks.h
        gt-tree-nested.h
        )],

    'tree-nrv.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h function.h vecprim.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h hard-reg-set.h
        predict.h predict.def cfghooks.h expr.h flags.h
        insn-config.h emit-rtl.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h gimple.h pointer-set.h ggc.h
        gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h timevar.h
        timevar.def tree-dump.h include/splay-tree.h
        tree-pass.h langhooks.h
        )],

    'tree-object-size.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h toplev.h
        bversion.h diagnostic.h pretty-print.h diagnostic.def
        tree-flow.h bitmap.h hard-reg-set.h basic-block.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-pass.h timevar.h timevar.def tree-ssa-propagate.h
        )],

    'tree-optimize.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h expr.h flags.h
        insn-config.h emit-rtl.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h gimple.h pointer-set.h ggc.h
        gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        langhooks.h toplev.h bversion.h tree-inline.h
        tree-mudflap.h graph.h cfgloop.h except.h plugin.h
        gcc-plugin.h highlev-plugin-common.h plugin.def
        )],

    'tree-outof-ssa.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h ggc.h
        gtype-desc.h basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h timevar.h
        timevar.def tree-dump.h include/splay-tree.h
        tree-pass.h toplev.h bversion.h expr.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h insn-config.h emit-rtl.h ssaexpand.h
        tree-ssa-live.h
        )],

    'tree-parloops.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h cfgloop.h tree-data-ref.h graphds.h
        lambda.h omega.h params.h params.def tree-chrec.h
        diagnostic.h pretty-print.h diagnostic.def tree-pass.h
        timevar.h timevar.def tree-scalar-evolution.h
        langhooks.h tree-vectorizer.h gt-tree-parloops.h
        )],

    'tree-phinodes.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h varray.h ggc.h gtype-desc.h basic-block.h
        bitmap.h sbitmap.h include/partition.h hard-reg-set.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        tree-flow.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        toplev.h bversion.h gt-tree-phinodes.h
        )],

    'tree-predcom.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h tm_p.h
        config/i386/i386-protos.h tm-preds.h cfgloop.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-data-ref.h graphds.h lambda.h omega.h params.h
        params.def tree-chrec.h tree-scalar-evolution.h
        diagnostic.h pretty-print.h diagnostic.def tree-pass.h
        timevar.h timevar.def tree-affine.h tree-inline.h
        )],

    'tree-pretty-print.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h output.h
        diagnostic.h pretty-print.h diagnostic.def real.h
        tree-flow.h bitmap.h hard-reg-set.h basic-block.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        langhooks.h tree-iterator.h tree-chrec.h tree-pass.h
        timevar.h timevar.def fixed-value.h value-prof.h
        )],

    'tree-profile.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h output.h regs.h varray.h
        include/obstack.h hard-reg-set.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h expr.h insn-config.h emit-rtl.h
        toplev.h bversion.h coverage.h gcov-io.h gcov-iov.h
        tree-flow.h gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def value-prof.h
        gt-tree-profile.h
        )],

    'tree-scalar-evolution.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h real.h rtl.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def cfgloop.h
        tree-chrec.h tree-scalar-evolution.h flags.h params.h
        params.def gt-tree-scalar-evolution.h
        )],

    'tree-sra.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h alloc-pool.h tm.h
        options.h config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h expr.h
        function.h vecprim.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h flags.h
        insn-config.h emit-rtl.h gimple.h pointer-set.h ggc.h
        gtype-desc.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def cfghooks.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def tree-flow.h
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        ipa-prop.h diagnostic.h pretty-print.h diagnostic.def
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def params.h params.def target.h
        )],

    'tree-switch-conversion.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h line-map.h params.h
        params.def flags.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h statistics.h
        vec.h double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h tree-flow.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h output.h tree-pass.h timevar.h
        timevar.def diagnostic.h pretty-print.h diagnostic.def
        tree-dump.h include/splay-tree.h
        )],

    'tree-ssa-address.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def flags.h tree-inline.h insn-config.h recog.h
        expr.h emit-rtl.h tree-affine.h target.h
        gt-tree-ssa-address.h
        )],

    'tree-ssa-alias.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h timevar.h timevar.def
        expr.h flags.h insn-config.h emit-rtl.h ggc.h
        gtype-desc.h langhooks.h diagnostic.h pretty-print.h
        diagnostic.def tree-dump.h include/splay-tree.h
        tree-pass.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def tree-flow.h cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-inline.h convert.h params.h
        params.def ipa-type-escape.h alloc-pool.h
        )],

    'tree-ssa-ccp.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h ggc.h gtype-desc.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h output.h
        expr.h insn-config.h emit-rtl.h diagnostic.h
        pretty-print.h diagnostic.def timevar.h timevar.def
        tree-dump.h include/splay-tree.h tree-pass.h
        tree-flow.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-ssa-propagate.h value-prof.h langhooks.h target.h
        toplev.h bversion.h dbgcnt.h dbgcnt.def
        )],

    'tree-ssa-coalesce.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h
        diagnostic.h pretty-print.h diagnostic.def bitmap.h
        tree-flow.h hard-reg-set.h basic-block.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h gimple.h pointer-set.h
        ggc.h gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        tree-ssa-live.h toplev.h bversion.h
        )],

    'tree-ssa-copy.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h ggc.h gtype-desc.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h output.h
        expr.h insn-config.h emit-rtl.h diagnostic.h
        pretty-print.h diagnostic.def timevar.h timevar.def
        tree-dump.h include/splay-tree.h tree-pass.h
        tree-flow.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-ssa-propagate.h langhooks.h cfgloop.h
        )],

    'tree-ssa-copyrename.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h gimple.h
        pointer-set.h ggc.h gtype-desc.h hard-reg-set.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h tree-ssa-operands.h gimple.def
        gsstruct.def flags.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-inline.h timevar.h timevar.def tree-dump.h
        include/splay-tree.h tree-pass.h tree-ssa-live.h
        langhooks.h
        )],

    'tree-ssa-dce.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h rtl.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        include/obstack.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        flags.h cfgloop.h tree-scalar-evolution.h
        )],

    'tree-ssa-dom.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h ggc.h gtype-desc.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h cfgloop.h
        output.h expr.h insn-config.h emit-rtl.h diagnostic.h
        pretty-print.h diagnostic.def timevar.h timevar.def
        tree-dump.h include/splay-tree.h tree-pass.h
        tree-flow.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        domwalk.h tree-ssa-propagate.h langhooks.h params.h
        params.def
        )],

    'tree-ssa-dse.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h timevar.h timevar.def diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-pass.h
        tree-dump.h include/splay-tree.h domwalk.h flags.h
        langhooks.h
        )],

    'tree-ssa-forwprop.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h timevar.h timevar.def diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-pass.h
        tree-dump.h include/splay-tree.h langhooks.h flags.h
        )],

    'tree-ssa-ifcombine.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h timevar.h timevar.def diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-pass.h tree-dump.h include/splay-tree.h
        )],

    'tree-ssa-live.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h diagnostic.h
        pretty-print.h diagnostic.def bitmap.h tree-flow.h
        hard-reg-set.h basic-block.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h gimple.h pointer-set.h ggc.h
        gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        tree-ssa-live.h toplev.h bversion.h debug.h flags.h
        )],

    'tree-ssa-loop-ch.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h tree-inline.h flags.h
        )],

    'tree-ssa-loop-im.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h domwalk.h params.h params.def
        flags.h tree-affine.h tree-ssa-propagate.h
        )],

    'tree-ssa-loop-ivcanon.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h tree-chrec.h
        tree-scalar-evolution.h params.h params.def flags.h
        tree-inline.h target.h
        )],

    'tree-ssa-loop-ivopts.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h expr.h flags.h insn-config.h
        emit-rtl.h recog.h tree-chrec.h tree-scalar-evolution.h
        params.h params.def langhooks.h tree-affine.h target.h
        )],

    'tree-ssa-loop-manip.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h cfglayout.h
        tree-scalar-evolution.h params.h params.def
        tree-inline.h langhooks.h
        )],

    'tree-ssa-loop-niter.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h diagnostic.h
        pretty-print.h diagnostic.def intl.h tree-flow.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def cfgloop.h
        tree-chrec.h tree-scalar-evolution.h tree-data-ref.h
        graphds.h lambda.h omega.h params.h params.def flags.h
        toplev.h bversion.h tree-inline.h
        )],

    'tree-ssa-loop-prefetch.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h expr.h flags.h insn-config.h
        emit-rtl.h recog.h tree-chrec.h tree-scalar-evolution.h
        toplev.h bversion.h params.h params.def langhooks.h
        tree-inline.h tree-data-ref.h graphds.h lambda.h
        omega.h optabs.h insn-codes.h
        )],

    'tree-ssa-loop-unswitch.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h params.h params.def tree-inline.h
        )],

    'tree-ssa-loop.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h output.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def cfgloop.h flags.h tree-inline.h
        tree-scalar-evolution.h toplev.h bversion.h
        tree-vectorizer.h tree-data-ref.h graphds.h lambda.h
        omega.h params.h params.def tree-chrec.h
        )],

    'tree-ssa-math-opts.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h flags.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h real.h timevar.h timevar.def
        tree-pass.h alloc-pool.h target.h diagnostic.h
        pretty-print.h diagnostic.def rtl.h fixed-value.h
        rtl.def reg-notes.def insn-notes.def genrtl.h expr.h
        insn-config.h emit-rtl.h optabs.h insn-codes.h
        )],

    'tree-ssa-operands.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h
        function.h vecprim.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h sbitmap.h varray.h include/partition.h
        predict.h predict.def cfghooks.h gimple.h pointer-set.h
        ggc.h gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-inline.h
        tree-pass.h timevar.h timevar.def toplev.h bversion.h
        langhooks.h
        )],

    'tree-ssa-phiopt.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h flags.h tm_p.h
        config/i386/i386-protos.h tm-preds.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h timevar.h timevar.def diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-pass.h
        tree-dump.h include/splay-tree.h langhooks.h domwalk.h
        )],

    'tree-ssa-phiprop.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h timevar.h timevar.def diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-pass.h
        tree-dump.h include/splay-tree.h langhooks.h flags.h
        )],

    'tree-ssa-pre.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def
        tree-inline.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def tree-flow.h
        cgraph.h cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def include/fibheap.h
        tree-iterator.h real.h alloc-pool.h flags.h langhooks.h
        cfgloop.h rtl.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tree-ssa-sccvn.h
        tree-scalar-evolution.h params.h params.def dbgcnt.h
        dbgcnt.def
        )],

    'tree-ssa-propagate.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h ggc.h gtype-desc.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h output.h
        expr.h insn-config.h emit-rtl.h diagnostic.h
        pretty-print.h diagnostic.def timevar.h timevar.def
        tree-dump.h include/splay-tree.h tree-pass.h
        tree-flow.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-ssa-propagate.h langhooks.h value-prof.h
        gt-tree-ssa-propagate.h
        )],

    'tree-ssa-reassoc.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def
        tree-inline.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def tree-flow.h
        cgraph.h cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def tree-iterator.h
        real.h alloc-pool.h langhooks.h cfgloop.h rtl.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h
        )],

    'tree-ssa-sccvn.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def
        tree-inline.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def tree-flow.h
        cgraph.h cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def include/fibheap.h
        tree-iterator.h real.h alloc-pool.h flags.h langhooks.h
        cfgloop.h rtl.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h params.h params.def
        tree-ssa-propagate.h tree-ssa-sccvn.h
        )],

    'tree-ssa-sink.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def
        tree-inline.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def tree-flow.h
        cgraph.h cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-dump.h include/splay-tree.h
        tree-pass.h timevar.h timevar.def include/fibheap.h
        tree-iterator.h real.h alloc-pool.h flags.h langhooks.h
        cfgloop.h rtl.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h
        )],

    'tree-ssa-structalias.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h include/obstack.h bitmap.h
        include/hashtab.h flags.h rtl.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h hard-reg-set.h
        basic-block.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h tree.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        vecprim.h cfghooks.h output.h tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-inline.h
        diagnostic.h pretty-print.h diagnostic.def toplev.h
        bversion.h tree-pass.h timevar.h timevar.def
        alloc-pool.h include/splay-tree.h params.h params.def
        gt-tree-ssa-structalias.h
        )],

    'tree-ssa-ter.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h diagnostic.h
        pretty-print.h diagnostic.def bitmap.h tree-flow.h
        hard-reg-set.h basic-block.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        vecprim.h cfghooks.h gimple.h pointer-set.h ggc.h
        gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        tree-ssa-live.h flags.h
        )],

    'tree-ssa-threadedge.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h ggc.h gtype-desc.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h cfgloop.h
        output.h expr.h insn-config.h emit-rtl.h diagnostic.h
        pretty-print.h diagnostic.def timevar.h timevar.def
        tree-dump.h include/splay-tree.h tree-pass.h
        tree-flow.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-ssa-propagate.h langhooks.h params.h params.def
        )],

    'tree-ssa-threadupdate.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h ggc.h gtype-desc.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h output.h
        expr.h insn-config.h emit-rtl.h diagnostic.h
        pretty-print.h diagnostic.def tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h
        )],

    'tree-ssa-uncprop.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h ggc.h gtype-desc.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h output.h
        expr.h insn-config.h emit-rtl.h diagnostic.h
        pretty-print.h diagnostic.def timevar.h timevar.def
        tree-dump.h include/splay-tree.h tree-pass.h
        tree-flow.h gimple.h pointer-set.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        domwalk.h tree-ssa-propagate.h langhooks.h
        )],

    'tree-ssa.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h flags.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h target.h ggc.h
        gtype-desc.h langhooks.h hard-reg-set.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        output.h expr.h insn-config.h emit-rtl.h diagnostic.h
        pretty-print.h diagnostic.def pointer-set.h tree-flow.h
        gimple.h tree-ssa-operands.h gimple.def gsstruct.def
        cgraph.h cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-inline.h timevar.h timevar.def
        tree-dump.h include/splay-tree.h tree-pass.h toplev.h
        bversion.h
        )],

    'tree-ssanames.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h varray.h ggc.h
        gtype-desc.h tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h sbitmap.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-pass.h
        timevar.h timevar.def
        )],

    'tree-stdarg.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h function.h
        vecprim.h langhooks.h diagnostic.h pretty-print.h
        diagnostic.def target.h tree-flow.h bitmap.h
        hard-reg-set.h basic-block.h sbitmap.h varray.h
        include/partition.h predict.h predict.def cfghooks.h
        gimple.h pointer-set.h ggc.h gtype-desc.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-pass.h timevar.h timevar.def
        tree-stdarg.h
        )],

    'tree-tailcall.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tm_p.h config/i386/i386-protos.h tm-preds.h
        hard-reg-set.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h predict.h predict.def
        function.h vecprim.h cfghooks.h tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        tree-dump.h include/splay-tree.h tree-pass.h timevar.h
        timevar.def diagnostic.h pretty-print.h diagnostic.def
        except.h flags.h langhooks.h dbgcnt.h dbgcnt.def
        )],

    'tree-vect-generic.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h options.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h tm.h config/vxworks-dummy.h
        config/i386/i386.h config/i386/unix.h config/i386/att.h
        config/dbxelf.h config/elfos.h config/svr4.h
        config/linux.h config/glibc-stdint.h
        config/i386/linux.h defaults.h insn-constants.h
        insn-flags.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h expr.h function.h
        vecprim.h flags.h insn-config.h emit-rtl.h insn-codes.h
        diagnostic.h pretty-print.h diagnostic.def optabs.h
        langhooks.h tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h sbitmap.h varray.h include/partition.h
        predict.h predict.def cfghooks.h gimple.h pointer-set.h
        ggc.h gtype-desc.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-iterator.h
        tree-pass.h timevar.h timevar.def
        gt-tree-vect-generic.h
        )],

    'tree-vect-patterns.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h target.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h hard-reg-set.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h expr.h flags.h
        insn-config.h emit-rtl.h optabs.h insn-codes.h params.h
        params.def tree-data-ref.h graphds.h lambda.h omega.h
        tree-chrec.h tree-vectorizer.h recog.h toplev.h
        bversion.h
        )],

    'tree-vect-data-refs.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h target.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h hard-reg-set.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h expr.h flags.h
        insn-config.h emit-rtl.h optabs.h insn-codes.h
        tree-chrec.h tree-scalar-evolution.h tree-vectorizer.h
        tree-data-ref.h graphds.h lambda.h omega.h params.h
        params.def toplev.h bversion.h
        )],

    'tree-vect-stmts.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h target.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h hard-reg-set.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h cfglayout.h
        expr.h flags.h insn-config.h emit-rtl.h recog.h
        optabs.h insn-codes.h toplev.h bversion.h
        tree-vectorizer.h tree-data-ref.h graphds.h lambda.h
        omega.h params.h params.def tree-chrec.h langhooks.h
        )],

    'tree-vect-loop.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h cfglayout.h
        expr.h flags.h insn-config.h emit-rtl.h recog.h
        optabs.h insn-codes.h params.h params.def toplev.h
        bversion.h tree-chrec.h tree-scalar-evolution.h
        tree-vectorizer.h tree-data-ref.h graphds.h lambda.h
        omega.h
        )],

    'tree-vect-loop-manip.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h basic-block.h bitmap.h sbitmap.h
        varray.h include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h cfglayout.h
        expr.h flags.h insn-config.h emit-rtl.h toplev.h
        bversion.h tree-scalar-evolution.h tree-vectorizer.h
        tree-data-ref.h graphds.h lambda.h omega.h params.h
        params.def tree-chrec.h langhooks.h
        )],

    'tree-vect-slp.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h target.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h hard-reg-set.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        diagnostic.h pretty-print.h diagnostic.def tree-flow.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h cfglayout.h
        expr.h flags.h insn-config.h emit-rtl.h recog.h
        optabs.h insn-codes.h tree-vectorizer.h tree-data-ref.h
        graphds.h lambda.h omega.h params.h params.def
        tree-chrec.h
        )],

    'tree-vectorizer.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h tree.h include/hashtab.h machmode.h
        insn-modes.h mode-classes.def input.h line-map.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h diagnostic.h pretty-print.h
        diagnostic.def tree-flow.h bitmap.h hard-reg-set.h
        basic-block.h sbitmap.h varray.h include/partition.h
        predict.h predict.def function.h vecprim.h cfghooks.h
        gimple.h pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h tree-dump.h
        include/splay-tree.h tree-pass.h timevar.h timevar.def
        cfgloop.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h cfglayout.h
        tree-vectorizer.h tree-data-ref.h graphds.h lambda.h
        omega.h params.h params.def tree-chrec.h
        )],

    'tree-vrp.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h ggc.h statistics.h
        gtype-desc.h flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h vec.h double-int.h mini-gmp.h alias.h
        all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h basic-block.h
        bitmap.h sbitmap.h varray.h include/partition.h
        hard-reg-set.h predict.h predict.def function.h
        vecprim.h cfghooks.h tree-flow.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h tree-pass.h timevar.h timevar.def
        tree-dump.h include/splay-tree.h diagnostic.h
        pretty-print.h diagnostic.def toplev.h bversion.h
        intl.h cfgloop.h rtl.h real.h fixed-value.h rtl.def
        reg-notes.def insn-notes.def genrtl.h
        tree-scalar-evolution.h tree-ssa-propagate.h
        tree-chrec.h
        )],

    'tree.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h flags.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h line-map.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h real.h tm_p.h
        config/i386/i386-protos.h tm-preds.h function.h
        vecprim.h toplev.h bversion.h ggc.h gtype-desc.h
        output.h target.h langhooks.h tree-inline.h gimple.h
        pointer-set.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def cfghooks.h tree-ssa-operands.h gimple.def
        gsstruct.def tree-iterator.h tree-flow.h cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h params.h params.def fixed-value.h
        tree-pass.h timevar.h timevar.def langhooks-def.h
        hooks.h diagnostic.h pretty-print.h diagnostic.def
        except.h debug.h intl.h gt-tree.h
        )],

    'unlink-if-ordinary.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'value-prof.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h expr.h function.h tree.h include/hashtab.h
        all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h vecprim.h
        flags.h insn-config.h emit-rtl.h hard-reg-set.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h predict.h predict.def cfghooks.h
        value-prof.h output.h recog.h optabs.h insn-codes.h
        regs.h ggc.h gtype-desc.h tree-flow.h gimple.h
        pointer-set.h tree-ssa-operands.h gimple.def
        gsstruct.def cgraph.h cif-code.def ipa-reference.h
        tree-ssa-alias.h tree-flow-inline.h diagnostic.h
        pretty-print.h diagnostic.def coverage.h gcov-io.h
        gcov-iov.h timevar.h timevar.def tree-pass.h toplev.h
        bversion.h
        )],

    'var-tracking.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h flags.h
        output.h insn-config.h reload.h alloc-pool.h
        include/fibheap.h regs.h expr.h emit-rtl.h timevar.h
        timevar.def tree-pass.h tree-flow.h gimple.h
        pointer-set.h ggc.h gtype-desc.h tree-ssa-operands.h
        gimple.def gsstruct.def cgraph.h cif-code.def
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        cselib.h target.h toplev.h bversion.h params.h
        params.def diagnostic.h pretty-print.h diagnostic.def
        recog.h
        )],

    'varpool.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h cgraph.h
        basic-block.h bitmap.h sbitmap.h varray.h
        include/partition.h hard-reg-set.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        cif-code.def langhooks.h diagnostic.h pretty-print.h
        diagnostic.def ggc.h gtype-desc.h timevar.h timevar.def
        debug.h target.h output.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def tree-flow.h
        ipa-reference.h tree-ssa-alias.h tree-flow-inline.h
        flags.h gt-varpool.h
        )],

    'varasm.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h rtl.h statistics.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h real.h vec.h fixed-value.h double-int.h
        mini-gmp.h alias.h rtl.def reg-notes.def insn-notes.def
        genrtl.h tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h flags.h function.h vecprim.h expr.h
        insn-config.h emit-rtl.h hard-reg-set.h regs.h varray.h
        basic-block.h bitmap.h sbitmap.h include/partition.h
        predict.h predict.def cfghooks.h output.h toplev.h
        bversion.h ggc.h gtype-desc.h langhooks.h tm_p.h
        config/i386/i386-protos.h tm-preds.h debug.h target.h
        targhooks.h tree-mudflap.h cgraph.h cif-code.def
        cfglayout.h tree-iterator.h gt-varasm.h
        )],

    'varray.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h varray.h ggc.h statistics.h
        gtype-desc.h include/hashtab.h
        )],

    'vec.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h ggc.h statistics.h gtype-desc.h
        vec.h coretypes.h toplev.h input.h line-map.h
        bversion.h include/hashtab.h
        )],

    'vmsdbgout.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h
        )],

    'web.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h toplev.h input.h
        line-map.h bversion.h rtl.h statistics.h machmode.h
        insn-modes.h mode-classes.def real.h vec.h
        fixed-value.h double-int.h mini-gmp.h alias.h rtl.def
        reg-notes.def insn-notes.def genrtl.h hard-reg-set.h
        flags.h include/obstack.h basic-block.h bitmap.h
        include/hashtab.h sbitmap.h varray.h
        include/partition.h predict.h predict.def function.h
        tree.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h vecprim.h cfghooks.h output.h
        df.h alloc-pool.h timevar.h timevar.def tree-pass.h
        )],

    'xatexit.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'xcoffout.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h rtl.h real.h
        fixed-value.h rtl.def reg-notes.def insn-notes.def
        genrtl.h flags.h toplev.h bversion.h output.h ggc.h
        gtype-desc.h target.h debug.h
        )],

    'xexit.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'xmalloc.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'xmemdup.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'xstrdup.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'xstrerror.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'xstrndup.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'c-cppbuiltin.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h version.h
        flags.h real.h c-common.h include/splay-tree.h cpplib.h
        ggc.h gtype-desc.h c-pragma.h output.h except.h
        sbitmap.h vecprim.h debug.h toplev.h bversion.h tm_p.h
        config/i386/i386-protos.h tm-preds.h target.h
        )],

    'c-pch.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h version.h cpplib.h
        symtab.h include/obstack.h line-map.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def input.h statistics.h vec.h
        double-int.h mini-gmp.h alias.h options.h all-tree.def
        tree.def c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h flags.h
        c-common.h include/splay-tree.h ggc.h gtype-desc.h
        output.h toplev.h bversion.h debug.h c-pragma.h
        langhooks.h hosthooks.h target.h tm.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h opts.h
        )],

    'cpp_files.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        mkdeps.h include/hashtab.h md5.h
        )],

    'cpp_init.c' => [qw(
        cpp_config.h cpp_system.h filenames.h
        include/libiberty.h include/ansidecl.h
        include/safe-ctype.h cpplib.h symtab.h
        include/obstack.h line-map.h internal.h cpp-id-data.h
        mkdeps.h localedir.h
        )],

    'cppdefault.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h cppdefault.h
        )],

    'intl.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h intl.h
        )],

    'prefix.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h prefix.h
        )],

    'strerror.c' => [qw(
        config.h auto-host.h include/ansidecl.h
        include/libiberty.h
        )],

    'toplev.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h line-map.h input.h tree.h
        include/hashtab.h machmode.h insn-modes.h
        mode-classes.def statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h version.h rtl.h
        real.h fixed-value.h rtl.def reg-notes.def
        insn-notes.def genrtl.h tm_p.h
        config/i386/i386-protos.h tm-preds.h flags.h
        insn-attr.h insn-addr.h vecprim.h insn-config.h
        hard-reg-set.h recog.h output.h except.h sbitmap.h
        function.h toplev.h bversion.h expr.h emit-rtl.h
        basic-block.h bitmap.h varray.h include/partition.h
        predict.h predict.def cfghooks.h intl.h ggc.h
        gtype-desc.h graph.h regs.h timevar.h timevar.def
        diagnostic.h pretty-print.h diagnostic.def params.h
        params.def reload.h ira.h dwarf2asm.h integrate.h
        debug.h target.h langhooks.h cfglayout.h cfgloop.h
        hosthooks.h cgraph.h cif-code.def opts.h coverage.h
        gcov-io.h gcov-iov.h value-prof.h alloc-pool.h
        tree-mudflap.h tree-pass.h gimple.h pointer-set.h
        tree-ssa-operands.h gimple.def gsstruct.def
        tree-ssa-alias.h plugin.h gcc-plugin.h
        highlev-plugin-common.h plugin.def dwarf2out.h dbxout.h
        )],

    'version.c' => [qw(
        version.h
        )],

    'builtins.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h machmode.h insn-modes.h
        mode-classes.def real.h rtl.h statistics.h input.h
        line-map.h vec.h fixed-value.h double-int.h mini-gmp.h
        alias.h rtl.def reg-notes.def insn-notes.def genrtl.h
        tree.h include/hashtab.h all-tree.def tree.def
        c-common.def builtins.def sync-builtins.def
        omp-builtins.def treestruct.def tree-check.h symtab.h
        include/obstack.h gimple.h pointer-set.h ggc.h
        gtype-desc.h hard-reg-set.h basic-block.h bitmap.h
        sbitmap.h varray.h include/partition.h predict.h
        predict.def function.h vecprim.h cfghooks.h
        tree-ssa-operands.h gimple.def gsstruct.def flags.h
        regs.h except.h insn-config.h expr.h emit-rtl.h
        optabs.h insn-codes.h libfuncs.h recog.h output.h
        typeclass.h toplev.h bversion.h tm_p.h
        config/i386/i386-protos.h tm-preds.h target.h
        langhooks.h tree-mudflap.h tree-flow.h cgraph.h
        cif-code.def ipa-reference.h tree-ssa-alias.h
        tree-flow-inline.h value-prof.h diagnostic.h
        pretty-print.h diagnostic.def
        )],

    'real.c' => [qw(
        config.h auto-host.h include/ansidecl.h system.h
        include/safe-ctype.h hwint.h filenames.h
        include/libiberty.h coretypes.h tm.h options.h
        config/vxworks-dummy.h config/i386/i386.h
        config/i386/unix.h config/i386/att.h config/dbxelf.h
        config/elfos.h config/svr4.h config/linux.h
        config/glibc-stdint.h config/i386/linux.h defaults.h
        insn-constants.h insn-flags.h tree.h include/hashtab.h
        machmode.h insn-modes.h mode-classes.def input.h
        line-map.h statistics.h vec.h double-int.h mini-gmp.h
        alias.h all-tree.def tree.def c-common.def builtins.def
        sync-builtins.def omp-builtins.def treestruct.def
        tree-check.h symtab.h include/obstack.h toplev.h
        bversion.h real.h tm_p.h config/i386/i386-protos.h
        tm-preds.h dfp.h
        )],

    'spec_qsort/spec_qsort.c' => [ 'spec_qsort/spec_qsort.h' ],
);

1;

# Editor settings: (please leave this at the end of the file)
# vim: set filetype=perl syntax=perl shiftwidth=4 tabstop=8 expandtab nosmarttab:
