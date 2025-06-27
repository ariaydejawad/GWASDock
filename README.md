# GWASDock

## Project Information
GWASDock is a collection of powerful genome-wide association study (GWAS) tools organized into reproducible docker build images. This project makes it much easier to reproduce GWAS experiments, port GWAS tools onto other computers, and be more productive with GWAS experiments using these tools. The project is an ongoing effort to make using GWAS tools as easy as possible, but its current version – with the working docker images for each GWAS tool – is more than enough to achieve the usability goals set out earlier. To help with the usage of docker, a dedicated **documentation** subdirectory has been created with all the command-line (or shell) commands to use docker, so that the user can easily build these GWAS images, and use them on their computers. The docker documentation for building and using each image for each GWAS tool is included/bundled into a **usage** subdirectory with its name. For example: **GAPIT** (Wang & Zhang, 2021) has a dedicated user's manual under the **documentation/usage/gapit-container** subdirectory from the project root – which is where this README.md file is located.

## GWASDock Usage Documentation
The usage documentation for each tool describes how to reliably reproduce the container of each tool from scratch. To reliably reproduce the container of each tool from scratch, the user needs to: (1) build the image of each tool's container using `docker buildx build` or `docker build` using the provided Dockerfiles, and (2) run each tool as a standalone container either interactively or non-interactively using the `docker run` commands. Note: there are many variations to the way that you can run these containers, so feel free to experiment with non-interactive methods of using these containers as part of your workflow. To get help with learning Docker, and what it can do, visit the official Docker reference documentation here: https://docs.docker.com/.

For each tool, the usage documenation is called **README.md**, and is located in its appropriate subdirectory under the **documentation/usage** project directory. The usage documentation comes in the form of a Markdown document that is automatically rendered by GitHub when you visit the respective tool's **documentation/usage** directory.

The usage documentation for each GWAS tool in this toolkit is located here:
- **PLINK Container:** [documentation/usage/plink-container](https://github.com/ariaydejawad/GWASDock/tree/main/documentation/usage/plink-container)
- **GCTA Container:** [documentation/usage/gcta-container](https://github.com/ariaydejawad/GWASDock/tree/main/documentation/usage/gcta-container)
	- **Computer Architecture Notes:** **GCTA** is the only tool in the toolkit currently that requires the use of a different Dockerfile for building and using it on a user's computer depending on whether they are using either a `linux/amd64` or `linux/aarch64` system. The usage documentation describes this key distinction, and provides the respective `docker buildx build` and `docker container run` commands for each architecture.
		- If you need to find out which computer architecture your computer supports, run `uname -a` to get this information. Based on this information, you will need to select the correct Dockerfile to use for building your desired image.
- **TASSEL Container:** [documentation/usage/tassel-container](https://github.com/ariaydejawad/GWASDock/tree/main/documentation/usage/tassel-container)
- **GAPIT Container:** [documentation/usage/gapit-container](https://github.com/ariaydejawad/GWASDock/tree/main/documentation/usage/gapit-container)

## Currently Supported GWAS Tools
Since each GWAS tool comes with its own set of reference manuals, each GWAS tool's manual has been linked under its entry in the "currently supported GWAS tools" list that follows. You can use these manuals to better understand how to use each tool either interactively or non-interactively.

The currently supported GWAS tools are:
- **PLINK** (versions 1.9 and 2.0) by Chang et al. (2015) (DOI: [10.1186/s13742-015-0047-8](https://doi.org/10.1186/s13742-015-0047-8))
	- The original **PLINK** (version 1.0) was developed by Purcell et al. (2007) (DOI: [10.1086/519795](https://doi.org/10.1086/519795))
	- **PLINK Usage Manual:** The website that hosts the **PLINK** usage manual is located here: https://www.cog-genomics.org/plink/1.9/general_usage.
- **GCTA** (version 1.94.1) by Yang et al. (2011) (DOI: [10.1016/j.ajhg.2010.11.011](https://doi.org/10.1016/j.ajhg.2010.11.011))
	- **GCTA Usage Manual:** The website that hosts the **GCTA** usage manual is located here: https://yanglab.westlake.edu.cn/software/gcta/#Overview.
- **GAPIT** (version 3) by Wang & Zhang (2021) (DOI: [10.1016/j.gpb.2021.08.005](https://doi.org/10.1016/j.gpb.2021.08.005))
	- Version 2 of **GAPIT** was developed by Tang et al. (2016) (DOI: [10.3835/plantgenome2015.11.0120](https://doi.org/10.3835/plantgenome2015.11.0120))
	- Version 1 (the original) of **GAPIT** was developed by Lipka et al. (2012) (DOI: [10.1093/bioinformatics/bts444](https://doi.org/10.1093/bioinformatics/bts444))
	- **GAPIT Usage Manual:** The website that hosts the usage manual of **GAPIT** is located here: https://github.com/jiabowang/GAPIT/blob/master/Documents/gapit_help_document.pdf.
- **TASSEL** (version 5.2.95) by Bradbury et al. (2007) (DOI: [10.1093/bioinformatics/btm308](https://doi.org/10.1093/bioinformatics/btm308))
	- **Note on TASSEL:** Only the command-line interface (CLI) for **TASSEL** is supported. The graphical user interface (GUI) version of **TASSEL** is less capable and stable than the CLI version, and it does not provide a scriptable interface to be used non-interactively as part of larger bioinformatics workflows. It is strongly recommended that you use the CLI version of **TASSEL** in any case, but it is nearly impossible to use the GUI version by design in the provided **TASSEL** container, since the user is expected to be familiar with the TASSEL CLI.
	- **TASSEL Usage Manual:** The website that hosts the **TASSEL** usage manual is located here: https://bitbucket.org/tasseladmin/tassel-5-source/wiki/UserManual.
- **FaST-LMM** (version 0.6.12) by Lippert et al. (2011) (DOI: [10.1038/nmeth.1681](https://doi.org/10.1038/nmeth.1681))
	- GWASDock supports the following fork/implementation of FaST-LMM by Carl Kadie (Microsoft): [FaST-LMM](https://github.com/fastlmm/FaST-LMM)
	- **FaST-LMM:** The usage documentation for **FaST-LMM** is located here: https://fastlmm.github.io/FaST-LMM/.

## System Requirements
A modest GNU/Linux computer is more than ample to use these tools. These recommended technical specifications are not exhaustive, and the user is always encouraged to get access to as much hardware horsepower they can get access to. Out of all the GWAS tools, **GAPIT** by Wang and Zhang (2021) is the most memory intensive, so the user is advised to use a GNU/Linux computer with access to more than 32 GiB of memory to be able to use **GAPIT** as it was designed/intended. Considering this, here are the recommended system specifications (hardware and software):

Hardware requirements:
- Central processing Unit (CPU): AMD Ryzen 5600 or Intel i5-10400 for x86 systems
- Memory: 32 GiB of random-access memory (RAM)
- Storage: Highly dependent on how much data you are working with, and how big the datasets are. The recommended minimum is 500 GiB of disk space, but this estimate can be easily insufficient if you are working with large datasets, and thus require more disk space to store them prior to running GWAS experiments.
- Graphical processing unit (GPU): Not necessary for this project, so use any GPU you want to.

Note: If you have a GNU/Linux **aarch64** system – i.e., an **arm** computer, then you will need an **arm** computer with: (1) at-least 32 GiB of memory, (2) a reasonable amount of allocatable disk space, and (3) a modestly powerful **arm** CPU. Anything with at-least 4 cores, and good multithreaded and singlethreaded performance will serve GWAS experiments well. Most Amazon Web Services (AWS) and Microsoft Azure cloud servers provide performant **arm** instances with ample memory to easily handle the needs of these tools, so you can easily run the docker images of this project on cloud systems.

Software requirements:
- Any GNU/Linux distribution – for example: **Arch Linux**, **Debian**, **Ubuntu**, and/or **Fedora Linux** - that can run docker and containerd
- Docker client version: at-least v28.0
- Docker engine version: at-least v28.0
- containerd version: at-least v2.0
- runc version: at-least at-least v1.0
- Docker init version: at-least v0.15.0

## References
Here is the references list:
- Bradbury, P. J., Zhang, Z., Kroon, D. E., Casstevens, T. M., Ramdoss, Y., & Buckler, E. S. (2007). TASSEL: Software for association mapping of complex traits in diverse samples. Bioinformatics, 23(19), 2633–2635. https://doi.org/10.1093/bioinformatics/btm308
- Chang, C. C., Chow, C. C., Tellier, L. C. A. M., Vattikuti, S., Purcell, S. M., & Lee, J. J. (2015). Second-generation PLINK: Rising to the challenge of larger and richer datasets. GigaScience, 4(1), 7. https://doi.org/10.1186/s13742-015-0047-8
- Lipka, A. E., Tian, F., Wang, Q., Peiffer, J., Li, M., Bradbury, P. J., Gore, M. A., Buckler, E. S., & Zhang, Z. (2012). GAPIT: Genome association and prediction integrated tool. Bioinformatics, 28(18), 2397–2399. https://doi.org/10.1093/bioinformatics/bts444
- Lippert, C., Listgarten, J., Liu, Y., Kadie, C. M., Davidson, R. I., & Heckerman, D. (2011). FaST linear mixed models for genome-wide association studies. Nature Methods, 8(10), 833–835. https://doi.org/10.1038/nmeth.1681
- Purcell, S., Neale, B., Todd-Brown, K., Thomas, L., Ferreira, M. A. R., Bender, D., Maller, J., Sklar, P., de Bakker, P. I. W., Daly, M. J., & Sham, P. C. (2007). PLINK: A tool set for whole-genome association and population-based linkage analyses. American Journal of Human Genetics, 81(3), 559–575. https://doi.org/10.1086/519795
- Tang, Y., Liu, X., Wang, J., Li, M., Wang, Q., Tian, F., Su, Z., Pan, Y., Liu, D., Lipka, A. E., Buckler, E. S., & Zhang, Z. (2016). GAPIT version 2: An enhanced integrated tool for genomic association and prediction. The Plant Genome, 9(2), 1–9. https://doi.org/10.3835/plantgenome2015.11.0120
- Wang, J., & Zhang, Z. (2021). GAPIT version 3: Boosting power and accuracy for genomic association and prediction. Genomics, Proteomics & Bioinformatics, 19(4), 629–640. https://doi.org/10.1016/j.gpb.2021.08.005
- Yang, J., Lee, S. H., Goddard, M. E., & Visscher, P. M. (2011). GCTA: A tool for genome-wide complex trait analysis. American Journal of Human Genetics, 88(1), 76–82. https://doi.org/10.1016/j.ajhg.2010.11.011
