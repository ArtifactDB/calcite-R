# R client for the calcite demonstrator

The **calcite** package implements an R client for interacting with the [**calcite** REST API](https://github.com/ArtifactDB/calcite-worker).
The **calcite** system provides an ExperimentHub-like data store for Bioconductor objects based on the [schemas here](https://github.com/ArtifactDB/calcite-schemas).
Its purpose is to demonstrate how the ArtifactDB framework can be easily adapted for other applications.
To get started, we can install the dependencies:

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

See the [user's guide](https://artifactdb.github.io/calcite-R/articles/userguide.html) for more details. 
