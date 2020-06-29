workflow test_location {
    call find_tools
}

task find_tools {
    command <<<
        ls -l /data/HG19_ROOT/hg19_random.fa
        echo "@@@@@@@@@@@@@"
        ls -l /data/HG19_ROOT/hg19_random.fa.fai
        echo "@@@@@@@@@@@@@"
        ls -l /data/HG19_ROOT/hg19_random.dict
        echo "@@@@@@@@@@@@@"
    >>>
    output{
        String message = read_string(stdout())
    }
    runtime {
        docker: "g3chen/mutect2@sha256:c9c87b456d10098326edd996669885a798c6f956c0ce47caee72f8fdc07c3eac"
    }
}
