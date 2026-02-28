# Retrieve A Data File

Load a data file from a source data project, or list versions of the
file.

## Usage

``` r
dcf_get_file(path, date = NULL, commit_hash = NULL, versions = FALSE)
```

## Arguments

- path:

  Path to the file.

- date:

  Date of the version to load; A `Date`, or `character` in the format
  `YYYY-MM-DD`. Will match to the nearest version.

- commit_hash:

  SHA signature of the committed version; can be the first 6 or so
  characters. Ignored if `date` is provided.

- versions:

  Logical; if `TRUE`, will return a list of available version, rather
  than a

## Value

If `versions` is `TRUE`, a `data.frame` with columns for the `hash`,
`author`, `date`, and `message` of each commit. Otherwise, the path to a
temporary file, if one was extracted.

## Examples

``` r
path <- "../../../pophive/pophive_demo/data/wastewater/raw/flua.csv.xz"
if (file.exists(path)) {
  # list versions
  versions <- dcf_get_file(path, versions = TRUE)
  print(versions[, c("date", "hash")])

  # extract a version to a temporary file
  temp_path <- dcf_get_file(path, "2025-05")
  basename(temp_path)
}
#>                              date                                     hash
#> 1  Thu Feb 26 03:42:48 2026 -0500 62e67f828464b6e263463828391b965153ef5e76
#> 2  Sat Feb 21 02:57:46 2026 +0000 27cc4a42f06ec76a45200e93f64e3a120cd5ede1
#> 3  Sat Feb 14 03:01:15 2026 +0000 c3c65aaea0c33f42ccb40af8876719f638455c21
#> 4   Sat Feb 7 02:58:42 2026 +0000 ddf9f96a6a6c317dce66b67a4d96451e39be09ad
#> 5  Sat Jan 31 02:56:54 2026 +0000 08497141c4531a07965c39dd6daa74ff9ad37e84
#> 6  Sat Jan 24 02:41:15 2026 +0000 82fbf03d1b4bdc0ac48bdbf31b14e4dce2cc1418
#> 7  Sat Jan 17 02:38:43 2026 +0000 a4d5b3eb34c94e805110a6969b9a962cba1cc031
#> 8  Sat Jan 10 02:39:48 2026 +0000 32df32f0e36162ee07e45f925a5ea842504290ac
#> 9   Tue Jan 6 02:43:16 2026 +0000 ba182c16ba090e0eb23d863124401a60f61c94c9
#> 10 Wed Dec 31 02:41:22 2025 +0000 279493b87f75dc3c77a53ce48005ebe42cbc18c2
#> 11 Sat Dec 20 02:37:18 2025 +0000 8b0d409c529d908252e808968b0b095d771b8613
#> 12 Sat Dec 13 02:37:56 2025 +0000 877bf127049b4779360983435d3205482f2b1c11
#> 13  Sat Dec 6 02:37:00 2025 +0000 6c9669d236a9409c9ca4ff3187cbfcdb31927e20
#> 14  Tue Dec 2 02:38:24 2025 +0000 ed20e66e79bc5a7939adc1af1610bc6f31e3dd5a
#> 15 Sat Nov 22 02:33:54 2025 +0000 b59fac32e66056e85e41430c91aad060958306a5
#> 16  Sun Nov 2 02:38:05 2025 +0000 c823cb2c44dcb6260ad0a901ba81e0acc801c6f3
#> 17  Sat Nov 1 09:57:43 2025 -0400 04fafdcf31a126e42642e6010a3100aa63edda81
#> 18 Wed Oct 15 02:35:00 2025 +0000 5563a50413876d209604a2c4fbac0fffbd4ba793
#> 19 Tue Oct 14 06:48:38 2025 -0400 076b852d31b5af16235aa56dde508fa73983d479
#> 20 Sat Sep 27 02:31:30 2025 +0000 cb8a41fa3da3ddedbbee4bf6153c208de7de3a01
#> 21 Sat Sep 20 02:31:17 2025 +0000 520394f79a87bf2fa0a4b1ae2213932e728b1570
#> 22 Thu Sep 18 02:33:21 2025 +0000 ac2f7e138d60f8a861a3d584e134a5fdf5ec78c9
#> 23 Wed Sep 17 15:46:06 2025 -0400 8522c4a6e1f0b30661504f0728e2fafceee4ecfb
#> 24 Sat Sep 13 02:27:37 2025 +0000 5d9483923815921ecb1ed700df782b695cb994eb
#> 25  Sat Sep 6 02:29:33 2025 +0000 65ff8e099fd579e330315b3f7859c406074832eb
#> 26 Sat Aug 30 02:31:18 2025 +0000 1bf85727accd512bdc8dd3100dede7295b604943
#> 27 Sat Aug 16 02:36:12 2025 +0000 ccd85b4da78bc580f3fd533c520d6fbf21bc181d
#> 28  Sat Aug 9 02:38:46 2025 +0000 2ef24d54247fb01628c6dc1ddccd071613280fd9
#> 29 Sat Jul 26 02:40:50 2025 +0000 81716bd29b0adbb4c45210c6f10317ab796ba1f5
#> 30 Sat Jul 19 02:39:02 2025 +0000 b5c6f34063227d1b6ba7e458f41faac7b754103a
#> 31 Fri Jul 18 15:34:47 2025 -0400 3c39f450353d516ee166f5f6686ced81c6d5ff75
#> 32 Fri Jul 18 06:05:49 2025 -0400 39732a153fa02c1a4350a9a998471ae61c7a8627
#> 33 Fri Jul 18 02:44:23 2025 +0000 c381b11f68d0f1a3447e824049659b6cc685d0c8
#> 34 Thu Jul 17 09:46:50 2025 -0400 8b9395792ca23c342cf25af097d86a519918e2e6
#> 35 Tue Jul 15 02:44:40 2025 +0000 78dd0978bc74bed8e26f7fedc13087bddd409404
#> 36 Mon Jul 14 11:10:58 2025 -0400 f397e907659bbc3c8bb2175232c8b3376562839b
#> 37 Sat Jul 12 02:42:02 2025 +0000 2ac6330bd528332cd2e3c1e94391a7c4fbde6d32
#> 38 Fri Jul 11 02:46:42 2025 +0000 14629520528fcd24cc0a90c1206458780a7ce08f
#> 39 Thu Jul 10 18:10:38 2025 -0400 ab6649b2b88fb7fc51f1a34f18a29dd40b5e6d11
#> 40  Tue Jul 8 02:35:33 2025 +0000 3afe62043b4290a4199d82721ba510b3fe93ba79
#> 41  Wed Jul 2 02:34:23 2025 +0000 440e5a9e4917c83424b6a3fe933715a22d5fb87b
#> 42  Tue Jul 1 15:11:58 2025 -0400 1ef46279c9b98850cdff0d5acfeda88e7d8d4c92
#> 43 Mon Jun 30 00:37:54 2025 +0000 eb977e93221277f616a1a46835ac3daa1f0186ae
#> 44 Mon Jun 23 00:38:01 2025 +0000 0576de553d7c11836e020501a500431af581654a
#> 45 Mon Jun 16 00:48:12 2025 +0000 04fa04500f67f1bdfb2c6cc02bb0bd3c430bf8bd
#> 46  Mon Jun 9 00:36:37 2025 +0000 d978116e3b12926798d8f573bc1d3e913d67a547
#> 47  Mon Jun 2 09:32:13 2025 +0000 784558d5a95e20f3950a36770f82a5a0fabebb21
#> 48 Tue May 27 13:56:02 2025 -0400 36914a3d9b47f91eba0b5d8dfddd357a700fd525
#> [1] "flua-36914a.csv.xz"
```
