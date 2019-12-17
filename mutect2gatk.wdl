version 1.0

workflow Mutect2GATK4 {
  input {
    File tumor_bam
    File? normal_bam
    String outputTumorNamePrefix = basename(tumor_bam, '.bam')
    String? outputNormalNamePrefix = basename(normal_bam, '.bam')
  }

  call runMuTect2GATK4 {
    input:
    tumor_bam = tumor_bam,
    normal_bam = normal_bam,
    outputPrefix = outputTumorNamePrefix
  }

  output {
    File outputMuTect2GATK4 = runMuTect2GATK4.outputMuTect2GATK4
  }

  parameter_meta {
  tumor_bam: "Input tumor file (bam or sam)."
  normal_bam: "Input normal file (bam or sam)."
  outputFileNamePrefix: "Output prefix to prefix output file names with."
}
  meta {
    author: "Alexander Fortuna"
    email: "alexander.fortuna@oicr.on.ca"
    description: "Workflow to run MuTect2GATK4"
    dependencies: [{
      name: "gatk/4.1.1.0",
      url: "https://software.broadinstitute.org/gatk/download/index"
    }]
  }
}

task runMuTect2GATK4 {
  input {
    File tumor_bam
    File normal_bam
    Int jobMemory = 16
    String outputTumorNamePrefix = outputTumorNamePrefix
    String gatk = "$GATK_ROOT/gatk"
    String refFasta = "$HG19_ROOT/hg19_random.fa"
    String outputPrefix = "OUTPUT"
    String mutectTag = "mutect2_gatk"
    String modules = "gatk/4.1.2.0 hg19/p13 samtools/1.9"
  }

  parameter_meta {
  gatk: "gatk to use"
  tumor_bam: "Input tumor file (bam or sam)"
  normal_bam: "Input normal file (bam or sam)"
  jobMemory: "Memory allocated for Job"
  refFasta: "Path to the reference fasta"
  mutectTag: "metric tag is used as a file extension for output"
  outputPrefix: "Output prefix, either input file basename or custom string"
  modules: "Environment module names and version to load (space separated) before command execution"
}

meta {
  output_meta : {
    outputMuTect2GATK4: "Workflow that takes output of BMPP (bam file) and calls SNPs, indels."
  }
}

command <<<

#tumor_name=$(samtools view -H ~{tumor_bam} | grep '@RG')
#normal_name=$(samtools view -H ~{normal_bam} | grep '@RG')

# We need to create these files regardless, even if they stay empty
  touch bamout.bam
  touch f1r2.tar.gz
  echo "" > normal_name.txt

  gatk --java-options "-Xmx~{command_mem}m" GetSampleName -R ~{reFasta} -I ~{tumor_bam} -O tumor_name.txt -encode
  tumor_command_line="-I ~{tumor_bam} -tumor `cat tumor_name.txt`"

  if [[ ! -z "~{normal_bam}" ]]; then
    gatk --java-options "-Xmx~{command_mem}m" GetSampleName -R ~{reFasta} -I ~{normal_bam} -O normal_name.txt -encode
    normal_command_line="-I ~{normal_bam} -normal `cat normal_name.txt`"
  fi

  ~{gatk} -Xmx~{jobMemory-6}G Mutect2 \
  -R ~{refFasta} \
  -I ~{tumor_bam} \
  -I ~{normal_bam} \
  -tumor $tumor_command_line \
  -normal $normal_command_line \
  -O "~{outputTumorNamePrefix}.~{mutectTag}.vcf"
>>>

runtime {
  memory:  "~{jobMemory} GB"
  modules: "~{modules}"
}

output {
  File outputMuTect2GATK4 = "~{outputTumorNamePrefix}.~{mutectTag}.vcf"
  }
}
