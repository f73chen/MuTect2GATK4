workflow test_location {
    call find_tools
}

task find_tools {
    command {
        ls $GATK_ROOT
        echo "@@@@@@@@@@@@@@@@"
        ls $JAVA_ROOT
        echo "@@@@@@@@@@@@@@@@"
        ls $RSTATS_ROOT
        echo "@@@@@@@@@@@@@@@@"
        ls $SAMTOOLS_ROOT
        echo "@@@@@@@@@@@@@@@@"
        ls $HTSLIB_ROOT
        echo "@@@@@@@@@@@@@@@@"

        echo $PATH
        echo "################"
        echo $MANPATH
        echo "################"
        echo $LD_LIBRARY_PATH
        echo "################"
        echo $PKG_CONFIG_PATH
        echo "################"
        echo $R_LIBS_SITE
        echo "################"
    }
    output{
        String message = read_string(stdout())
    }
    runtime {
        docker: "g3chen/mutect2@sha256:c9c87b456d10098326edd996669885a798c6f956c0ce47caee72f8fdc07c3eac"
        modules: "gatk/4.1.6.0 samtools/1.9"
    }
}
