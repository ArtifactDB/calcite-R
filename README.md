# R client for the calcite demonstrator

This repository contains the **calcite** R package, which implements an R client for interacting with the [**calcite** REST API](https://github.com/ArtifactDB/calcite-worker).
It is effectively a wrapper around the [**alabaster**](https://github.com/ArtifactDB/alabaster.base) framework for saving/loading Bioconductor objects,
combined with functions from the [**zircon**](https://github.com/ArtifactDB/zircon-R) R client to pull/save data from the **calcite** API.

To get started, we can install the dependencies (or we can use the [Docker image](https://github.com/ArtifactDB/calcite-docker/pkgs/container/calcite-docker%2Fbuilder)):

```r
devtools::install_github("ArtifactDB/alabaster.schemas")
devtools::install_github("ArtifactDB/alabaster.base")
devtools::install_github("ArtifactDB/zircon-R")
devtools::install_github("ArtifactDB/calcite-R")
```

Then we can start pulling down (and uploading) Bioconductor objects with ExperimentHub-like annotation.
For example:

```r
library(calcite)
(id <- exampleID())
## [1] "test:my_first_df@v1"

(obj <- fetchObject(id))
## DataFrame with 10 rows and 4 columns
##            X           Y        Z                  AA
##    <integer> <character> <factor>         <DataFrame>
## 1          1           A        a 0.221781: 0.1249998
## 2          2           B        b 0.331854:-0.9385503
## 3          3           C        c 0.807343: 1.3094641
## 4          4           D        d 0.483355:-0.6231195
## 5          5           E        e 0.108293:-0.0249276
## 6          6           F        f 0.466883: 0.8491610
## 7          7           G        g 0.243697:-0.4783389
## 8          8           H        h 0.848236: 0.4384521
## 9          9           I        i 0.316582: 0.2180794
## 10        10           J        j 0.582001: 0.7062769

str(objectAnnotation(obj))
## List of 8
##  $ title       : chr "FOO"
##  $ description : chr "I am a data frame"
##  $ maintainers :List of 1
##   ..$ :List of 2
##   .. ..$ name : chr "Aaron Lun"
##   .. ..$ email: chr "infinite.monkeys.with.keyboards@gmail.com"
##  $ species     : int 9606
##  $ genome      :List of 1
##   ..$ :List of 2
##   .. ..$ id    : chr "hg38"
##   .. ..$ source: chr "UCSC"
##  $ origin      :List of 1
##   ..$ :List of 2
##   .. ..$ source: chr "PubMed"
##   .. ..$ id    : chr "123456789"
##  $ bioc_version: chr "3.16"
##  $ _extra      :List of 10
##   ..$ $schema      : chr "csv_data_frame/v1.json"
##   ..$ id           : chr "test:my_first_df/simple.csv.gz@v1"
##   ..$ project_id   : chr "test"
##   ..$ version      : chr "v1"
##   ..$ metapath     : chr "my_first_df/simple.csv.gz"
##   ..$ meta_indexed : chr "2022-10-07T19:19:01.049Z"
##   ..$ meta_uploaded: chr "2022-10-07T19:18:39.254Z"
##   ..$ uploaded     : chr "2022-10-07T19:18:39.254Z"
##   ..$ permissions  :List of 5
##   .. ..$ scope       : chr "project"
##   .. ..$ read_access : chr "public"
##   .. ..$ write_access: chr "owners"
##   .. ..$ owners      : chr "ArtifactDB-bot"
##   .. ..$ viewers     : list()
```

If the appropriate **alabaster** packages are installed, we can be more ambitious and pull down some more interesting objects:

```r
# Pulling down the Zeisel scRNA-seq dataset:
fetchObject("test:my_first_sce@v1")
## class: SingleCellExperiment
## dim: 20006 3005
## metadata(1): .internal
## assays(1): counts
## rownames(20006): Tspan12 Tshz1 ... mt-Rnr1 mt-Nd4l
## rowData names(1): featureType
## colnames(3005): 1772071015_C02 1772071017_G12 ... 1772066098_A12
##   1772058148_F03
## colData names(10): tissue group # ... level1class level2class
## reducedDimNames(0):
## mainExpName: endogenous
## altExpNames(2): ERCC repeat

# Pulling down the classic airway dataset:
fetchObject("airway:airway@1.16.0")
## class: RangedSummarizedExperiment
## dim: 64102 8
## metadata(1): .internal
## assays(1): counts
## rownames(64102): ENSG00000000003 ENSG00000000005 ... LRG_98 LRG_99
## rowData names(0):
## colnames(8): SRR1039508 SRR1039509 ... SRR1039520 SRR1039521
## colData names(9): SampleName cell ... Sample BioSample

# Pulling down some 10X Genomics Visium data:
fetchObject("tenx:visium/olfactory@v1")
## class: SpatialExperiment
## dim: 32285 1185
## metadata(1): .internal
## assays(1): counts
## rownames(32285): ENSMUSG00000051951 ENSMUSG00000089699 ...
##   ENSMUSG00000095019 ENSMUSG00000095041
## rowData names(1): symbol
## colnames(1185): AAACAAGTATCTCCCA-1 AAACCGGGTAGGTACC-1 ...
##   TTGTTTCACATCCAGG-1 TTGTTTCCATACAACT-1
## colData names(4): in_tissue array_row array_col sample_id
## reducedDimNames(0):
## mainExpName: NULL
## altExpNames(0):
## spatialCoords names(2) : pxl_col_in_fullres pxl_row_in_fullres
## imgData names(4): sample_id image_id data scaleFactor
```

See the [user's guide](https://artifactdb.github.io/calcite-R/articles/userguide.html) for more details. 
