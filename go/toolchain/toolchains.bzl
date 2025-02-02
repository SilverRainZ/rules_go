load(
    "//go/private:go_toolchain.bzl",
    "generate_toolchains",
    "go_toolchain",
)
load(
    "//go/private:sdk.bzl",
    "go_download_sdk",
    "go_host_sdk",
)
load(
    "//go/private:nogo.bzl",
    "go_register_nogo",
)
load(
    "//go/platform:list.bzl",
    "GOARCH",
    "GOOS",
    "GOOS_GOARCH",
)
load(
    "@io_bazel_rules_go//go/private:skylib/lib/versions.bzl",
    "versions",
)

DEFAULT_VERSION = "1.12"

MIN_SUPPORTED_VERSION = "1.9"

SDK_REPOSITORIES = {
    "1.12": {
        "darwin_amd64": ("go1.12.darwin-amd64.tar.gz", "6c7e07349403f71588ef4e93a6d4ae31f8e5de1497a0a42fd998fe9b6bd07c8e"),
        "freebsd_386": ("go1.12.freebsd-386.tar.gz", "5f66cc122e91249d9b371b2c8635b0b50db513812e3efaf9d6defbc28bff3a1c"),
        "freebsd_amd64": ("go1.12.freebsd-amd64.tar.gz", "b4c063a3f39de4f837475cb982507926d7cab4f64d35e1dc0d6dce555b3fe143"),
        "linux_386": ("go1.12.linux-386.tar.gz", "3ac1db65a6fa5c13f424b53ee181755429df0c33775733cede1e0d540440fd7b"),
        "linux_amd64": ("go1.12.linux-amd64.tar.gz", "750a07fef8579ae4839458701f4df690e0b20b8bcce33b437e4df89c451b6f13"),
        "linux_arm64": ("go1.12.linux-arm64.tar.gz", "b7bf59c2f1ac48eb587817a2a30b02168ecc99635fc19b6e677cce01406e3fac"),
        "linux_arm": ("go1.12.linux-armv6l.tar.gz", "ea0636f055763d309437461b5817452419411eb1f598dc7f35999fae05bcb79a"),
        "linux_ppc64le": ("go1.12.linux-ppc64le.tar.gz", "5be21e7035efa4a270802ea04fb104dc7a54e3492641ae44632170b93166fb68"),
        "linux_s390x": ("go1.12.linux-s390x.tar.gz", "c0aef360b99ebb4b834db8b5b22777b73a11fa37b382121b24bf587c40603915"),
        "windows_386": ("go1.12.windows-386.zip", "c6606bfdc4d8b080fc40f72a072eb380ead77a02a4f99a6b953df6d9c7029970"),
        "windows_amd64": ("go1.12.windows-amd64.zip", "880ced1aecef08b3471a84381b6c7e2c0e846b81dd97ecb629b534d941f282bd"),
    },
    "1.11.5": {
        "darwin_amd64": ("go1.11.5.darwin-amd64.tar.gz", "b970d8fdd5245193073395ce7b7775dd9deea980d4ce5e68b3b80ee9edcf2afc"),
        "freebsd_386": ("go1.11.5.freebsd-386.tar.gz", "29d208de22cf4561404f4e4866cbb3d937d1043ce65e0a4e4bb88a8c8ac754ea"),
        "freebsd_amd64": ("go1.11.5.freebsd-amd64.tar.gz", "edd594da33d497a3499b362af3a3b3281c2e1de2b68b869154d4151aa82d85e2"),
        "linux_386": ("go1.11.5.linux-386.tar.gz", "acd8e05f8d3eed406e09bb58eab89de3f0a139d4aef15f74adeed2d2c24cb440"),
        "linux_amd64": ("go1.11.5.linux-amd64.tar.gz", "ff54aafedff961eb94792487e827515da683d61a5f9482f668008832631e5d25"),
        "linux_arm64": ("go1.11.5.linux-arm64.tar.gz", "6ee9a5714444182a236d3cc4636e74cfc5e24a1bacf0463ac71dcf0e7d4288ed"),
        "linux_arm": ("go1.11.5.linux-armv6l.tar.gz", "b26b53c94923f78955236386fee0725ef4e76b6cb47e0df0ed0c0c4724e7b198"),
        "linux_ppc64le": ("go1.11.5.linux-ppc64le.tar.gz", "66e83152c68cb35d41f21453377d6a811585c9e01a6ac54b19f7a6e2cbb3d1f5"),
        "linux_s390x": ("go1.11.5.linux-s390x.tar.gz", "56209e5498c64a8338cd6f0fe0c2e2cbf6857c0acdb10c774894f0cc0d19f413"),
        "windows_386": ("go1.11.5.windows-386.zip", "b569f7a45056ab810364d7ac9ee6357e9a098fc3e4c75e016948736fa93ee229"),
        "windows_amd64": ("go1.11.5.windows-amd64.zip", "1c734fe614fa052f44694e993f2d06f24a56b6703ee46fdfb2b9bf277819fe40"),
    },
    "1.11.4": {
        "darwin_amd64": ("go1.11.4.darwin-amd64.tar.gz", "48ea987fb610894b3108ecf42e7a4fd1c1e3eabcaeb570e388c75af1f1375f80"),
        "freebsd_386": ("go1.11.4.freebsd-386.tar.gz", "7c302a5fcb25c7a4d370e856218b748994bbb129810306260293cdfba0a80650"),
        "freebsd_amd64": ("go1.11.4.freebsd-amd64.tar.gz", "e5a99add3e60e38ef559e211584bb09a883ccc46a6fb1432dcaa9fd052689b71"),
        "linux_386": ("go1.11.4.linux-386.tar.gz", "cecd2da1849043237d5f0756a93d601db6798fa3bb27a14563d201088aa415f3"),
        "linux_amd64": ("go1.11.4.linux-amd64.tar.gz", "fb26c30e6a04ad937bbc657a1b5bba92f80096af1e8ee6da6430c045a8db3a5b"),
        "linux_arm64": ("go1.11.4.linux-arm64.tar.gz", "b76df430ba8caff197b8558921deef782cdb20b62fa36fa93f81a8c08ab7c8e7"),
        "linux_arm": ("go1.11.4.linux-armv6l.tar.gz", "9f7a71d27fef69f654a93e265560c8d9db1a2ca3f1dcdbe5288c46facfde5821"),
        "linux_ppc64le": ("go1.11.4.linux-ppc64le.tar.gz", "1f10146826acd56716b00b9188079af53823ddd79ceb6362e78e2f3aafb370ab"),
        "linux_s390x": ("go1.11.4.linux-s390x.tar.gz", "4467442dacf89eb94c5d6f9f700204cb360be82db60e6296cc2ef8d0e890cd42"),
        "windows_386": ("go1.11.4.windows-386.zip", "bc25ea25406878986f91c92ae802f25f033cb0163b4aeac7e7185f71d0ede788"),
        "windows_amd64": ("go1.11.4.windows-amd64.zip", "eeb20e21702f2b9469d9381df5de85e2f731b64a1f54effe196d0f7d0227fe14"),
    },
    "1.11.3": {
        "darwin_amd64": ("go1.11.3.darwin-amd64.tar.gz", "3d164d44fcb06a4bbd69d19d8d91308d601f7d855a1037346389644803fdf148"),
        "freebsd_386": ("go1.11.3.freebsd-386.tar.gz", "2b4aacf3dc09c8b210fe3daf00f7c17c97d29503070200ba46e04f2d93790672"),
        "freebsd_amd64": ("go1.11.3.freebsd-amd64.tar.gz", "29b3fcc8d80ac1ea10cd82ca78d3dac4e7242333b882855ea7bc8e3a9d974116"),
        "linux_386": ("go1.11.3.linux-386.tar.gz", "c3fadf7f8652c060e18b7907fb8e15b853955b25aa661dbd991f6d6bc581d7a9"),
        "linux_amd64": ("go1.11.3.linux-amd64.tar.gz", "d20a4869ffb13cee0f7ee777bf18c7b9b67ef0375f93fac1298519e0c227a07f"),
        "linux_arm64": ("go1.11.3.linux-arm64.tar.gz", "723c54cb081dd629a44d620197e4a789dccdfe6dee7f8b4ad7a6659f76952056"),
        "linux_arm": ("go1.11.3.linux-armv6l.tar.gz", "384933e6e97b74c5125011c8f0539362bbed5a015978a34e441d7333d8e519b9"),
        "linux_ppc64le": ("go1.11.3.linux-ppc64le.tar.gz", "57c89a047ef4f539580af4cadebf1364a906891b065afa0664592e72a034b0ee"),
        "linux_s390x": ("go1.11.3.linux-s390x.tar.gz", "183258709c051ceb2900dee5ee681abb0bc440624c8f657374bde2a5658bef27"),
        "windows_386": ("go1.11.3.windows-386.zip", "07a38035d642ae81820551ce486f2ac7d541c0caf910659452b4661656db0691"),
        "windows_amd64": ("go1.11.3.windows-amd64.zip", "bc168207115eb0686e226ed3708337b161946c1acb0437603e1221e94f2e1f0f"),
    },
    "1.11.2": {
        "darwin_amd64": ("go1.11.2.darwin-amd64.tar.gz", "be2a9382ef85792280951a78e789e8891ddb1df4ac718cd241ea9d977c85c683"),
        "freebsd_386": ("go1.11.2.freebsd-386.tar.gz", "7daf8c1995e6eb343c4b487ba4d6b8fb5463cdead8a8bde867a25cc7168ff77b"),
        "freebsd_amd64": ("go1.11.2.freebsd-amd64.tar.gz", "a0b46726b102067bdd9a9b863f2bce4d23e4478118162bb9b2362733eb28cabf"),
        "linux_386": ("go1.11.2.linux-386.tar.gz", "e74f2f37b43b9b1bcf18008a11e0efb8921b41dff399a4f48ac09a4f25729881"),
        "linux_amd64": ("go1.11.2.linux-amd64.tar.gz", "1dfe664fa3d8ad714bbd15a36627992effd150ddabd7523931f077b3926d736d"),
        "linux_arm64": ("go1.11.2.linux-arm64.tar.gz", "98a42b9b8d3bacbcc6351a1e39af52eff582d0bc3ac804cd5a97ce497dd84026"),
        "linux_arm": ("go1.11.2.linux-armv6l.tar.gz", "b9d16a8eb1f7b8fdadd27232f6300aa8b4427e5e4cb148c4be4089db8fb56429"),
        "linux_ppc64le": ("go1.11.2.linux-ppc64le.tar.gz", "23291935a299fdfde4b6a988ce3faa0c7a498aab6d56bbafbf1e7476468529a3"),
        "linux_s390x": ("go1.11.2.linux-s390x.tar.gz", "a67ef820ef8cfecc8d68c69dd5bf513aaf647c09b6605570af425bf5fe8a32f0"),
        "windows_386": ("go1.11.2.windows-386.zip", "c0c5ab568d9cf260cd7d281e0a489ef91f4b943813d99dac78b61607dca17283"),
        "windows_amd64": ("go1.11.2.windows-amd64.zip", "086c59df0dce54d88f30edd50160393deceb27e73b8d6b46b9ee3f88b0c02e28"),
    },
    "1.11.1": {
        "darwin_amd64": ("go1.11.1.darwin-amd64.tar.gz", "1f2b29c8b08a140f06c88d055ad68104ccea9ca75fd28fbc95fe1eeb61a29bef"),
        "freebsd_386": ("go1.11.1.freebsd-386.tar.gz", "db02787955495a4128811705dabf1b09c6d9674d59ebf93bc7be40a1ead7d91f"),
        "freebsd_amd64": ("go1.11.1.freebsd-amd64.tar.gz", "b2618f92bf5365c3e4f2a1f82997505d6356364310fdc0b9137734c4c9df29d8"),
        "linux_386": ("go1.11.1.linux-386.tar.gz", "52935db83719739d84a389a8f3b14544874fba803a316250b8d596313283aadf"),
        "linux_amd64": ("go1.11.1.linux-amd64.tar.gz", "2871270d8ff0c8c69f161aaae42f9f28739855ff5c5204752a8d92a1c9f63993"),
        "linux_arm64": ("go1.11.1.linux-arm64.tar.gz", "25e1a281b937022c70571ac5a538c9402dd74bceb71c2526377a7e5747df5522"),
        "linux_arm": ("go1.11.1.linux-armv6l.tar.gz", "bc601e428f458da6028671d66581b026092742baf6d3124748bb044c82497d42"),
        "linux_ppc64le": ("go1.11.1.linux-ppc64le.tar.gz", "f929d434d6db09fc4c6b67b03951596e576af5d02ff009633ca3c5be1c832bdd"),
        "linux_s390x": ("go1.11.1.linux-s390x.tar.gz", "93afc048ad72fa2a0e5ec56bcdcd8a34213eb262aee6f39a7e4dfeeb7e564c9d"),
        "windows_386": ("go1.11.1.windows-386.zip", "5cc3681c954e23d40b0c2565765ec34f4b4e834348e03e1d1e6fd1c3a75b8202"),
        "windows_amd64": ("go1.11.1.windows-amd64.zip", "230a08d4260ded9d769f072512a49bffe8bfaff8323e839c2db7cf7c9c788130"),
    },
    "1.11": {
        "darwin_amd64": ("go1.11.darwin-amd64.tar.gz", "9749e6cb9c6d05cf10445a7c9899b58e72325c54fee9783ed1ac679be8e1e073"),
        "freebsd_386": ("go1.11.freebsd-386.tar.gz", "e4c2a9bd43932cb8f3226e866737e4a0f8cdda93db9d82754a0ffea04af1a259"),
        "freebsd_amd64": ("go1.11.freebsd-amd64.tar.gz", "535a7561a229bfe7bece68c8e315421fd9fbbd3a599b461944113c8d8240b28f"),
        "linux_386": ("go1.11.linux-386.tar.gz", "1a91932b65b4af2f84ef2dce10d790e6a0d3d22c9ea1bdf3d8c4d9279dfa680e"),
        "linux_amd64": ("go1.11.linux-amd64.tar.gz", "b3fcf280ff86558e0559e185b601c9eade0fd24c900b4c63cd14d1d38613e499"),
        "linux_arm64": ("go1.11.linux-arm64.tar.gz", "e4853168f41d0bea65e4d38f992a2d44b58552605f623640c5ead89d515c56c9"),
        "linux_arm": ("go1.11.linux-armv6l.tar.gz", "8ffeb3577d8ca5477064f1cb8739835973c866487f2bf81df1227eaa96826acd"),
        "linux_ppc64le": ("go1.11.linux-ppc64le.tar.gz", "e874d617f0e322f8c2dda8c23ea3a2ea21d5dfe7177abb1f8b6a0ac7cd653272"),
        "linux_s390x": ("go1.11.linux-s390x.tar.gz", "c113495fbb175d6beb1b881750de1dd034c7ae8657c30b3de8808032c9af0a15"),
        "windows_386": ("go1.11.windows-386.zip", "d3279f0e3d728637352eff0aa1e11268a0eb01f13644bcbce1c066139f5a90db"),
        "windows_amd64": ("go1.11.windows-amd64.zip", "29f9291270f0b303d0b270f993972ead215b1bad3cc674a0b8a09699d978aeb4"),
    },
    "1.10.8": {
        "darwin_amd64": ("go1.10.8.darwin-amd64.tar.gz", "f41bc914a721ac98a187df824b3b40f0a7f35bfb3c6d31221bdd940d537d3c28"),
        "freebsd_386": ("go1.10.8.freebsd-386.tar.gz", "029219c9588fd6af498898e783963c7ce3489270304987c561990d8d01169d7b"),
        "freebsd_amd64": ("go1.10.8.freebsd-amd64.tar.gz", "fc1ab404793cb9322e6e7348c274bf7d3562cc8bfb7b17e3b7c6e5787c89da2b"),
        "linux_386": ("go1.10.8.linux-386.tar.gz", "10202da0b7f2a0f2c2ec4dd65375584dd829ce88ccc58e5fe1fa1352e69fecaf"),
        "linux_amd64": ("go1.10.8.linux-amd64.tar.gz", "d8626fb6f9a3ab397d88c483b576be41fa81eefcec2fd18562c87626dbb3c39e"),
        "linux_arm64": ("go1.10.8.linux-arm64.tar.gz", "0921a76e78022ec2ae217e85b04940e2e9912b4c3218d96a827deedb9abe1c7b"),
        "linux_arm": ("go1.10.8.linux-armv6l.tar.gz", "6fdbc67524fc4c15fc87014869dddce9ecda7958b78f3cb1bbc5b0a9b61bfb95"),
        "linux_ppc64le": ("go1.10.8.linux-ppc64le.tar.gz", "9054bcc7582ebb8a69ca43447a38e4b9ea11d08f05511cc7f13720e3a12ff299"),
        "linux_s390x": ("go1.10.8.linux-s390x.tar.gz", "6f71b189c6cf30f7736af21265e992990cb0374138b7a70b0880cf8579399a69"),
        "windows_386": ("go1.10.8.windows-386.zip", "9ded97d830bef3734ea6de70df0159656d6a63e01484175b34d72b8db326bda0"),
        "windows_amd64": ("go1.10.8.windows-amd64.zip", "ab63b55c349f75cce4b93aefa9b52828f50ebafb302da5057db0e686d7873d7a"),
    },
    "1.10.7": {
        "darwin_amd64": ("go1.10.7.darwin-amd64.tar.gz", "700725a36d29d6e5d474a887acbf490c3d2762d719bdfef8370e22198077297d"),
        "freebsd_386": ("go1.10.7.freebsd-386.tar.gz", "d45bd54c38169ba228a67a17c92560e5a455405f6f5116a030c512510b06987c"),
        "freebsd_amd64": ("go1.10.7.freebsd-amd64.tar.gz", "21c9bda5fa37d668348e65b2374de6da84c85d601e45bbba4d8e2c86450f2a95"),
        "linux_386": ("go1.10.7.linux-386.tar.gz", "55cd25e550cb8ce8250dbc9eda56b9c10b3097c7f6beed45066fbaaf8c6c1ebd"),
        "linux_amd64": ("go1.10.7.linux-amd64.tar.gz", "1aabe10919048822f3bb1865f7a22f8b78387a12c03cd573101594bc8fb33579"),
        "linux_arm64": ("go1.10.7.linux-arm64.tar.gz", "cb5a274f7c8f6186957e4503e724dda8aeffe84b76a146748c55ea5bb22d9ae4"),
        "linux_arm": ("go1.10.7.linux-armv6l.tar.gz", "1f81c995f829c8fc7def4d0cc1bde63cac1834386e6f650f2cd7be56ab5e8b98"),
        "linux_ppc64le": ("go1.10.7.linux-ppc64le.tar.gz", "11279ffebfcfa875b0552839d428cc72e2056e68681286429b57173c0da91fb4"),
        "linux_s390x": ("go1.10.7.linux-s390x.tar.gz", "e0d7802029ed8d2720a2b27ec1816e71cb29f818380abb8b449080e97547881e"),
        "windows_386": ("go1.10.7.windows-386.zip", "bbd297a456aded5dcafe91194aafec883802cd0982120c735d15a39810248ea7"),
        "windows_amd64": ("go1.10.7.windows-amd64.zip", "791e2d5a409932157ac87f4da7fa22d5e5468b784d5933121e4a747d89639e15"),
    },
    "1.10.6": {
        "darwin_amd64": ("go1.10.6.darwin-amd64.tar.gz", "419e7a775c39074ff967b4e66fa212eb4fd310b1f15675ce13977b57635dd3a8"),
        "freebsd_386": ("go1.10.6.freebsd-386.tar.gz", "d1f0aef497588865967256030cb676c6c62f6a4b53649814e753ae150fbaa960"),
        "freebsd_amd64": ("go1.10.6.freebsd-amd64.tar.gz", "194a1a39a96bb8d7ed8370dae7768db47109f628aea4f1588f677f66c384955a"),
        "linux_386": ("go1.10.6.linux-386.tar.gz", "171fe6cbecb2845b875a35ac7ad758d4c0c5bd03f330fa35d340de85b9070e71"),
        "linux_amd64": ("go1.10.6.linux-amd64.tar.gz", "acbdedf28b55b38d2db6f06209a25a869a36d31bdcf09fd2ec3d40e1279e0592"),
        "linux_arm64": ("go1.10.6.linux-arm64.tar.gz", "0fcbfbcbf6373c0b6876786900a4a100c1ed9af86bd3258f23ab498cca4c02a1"),
        "linux_arm": ("go1.10.6.linux-armv6l.tar.gz", "4da252fc7e834b7ce35d349fb581aa84a08adece926a0b9a8e4216451ffcb11e"),
        "linux_ppc64le": ("go1.10.6.linux-ppc64le.tar.gz", "ebd7e4688f3e1baabbc735453b19c6c27116e1f292bf46622123bfc4c160c747"),
        "linux_s390x": ("go1.10.6.linux-s390x.tar.gz", "0223daa57bdef5bf85d308f6d2793c58055d294c13cbaca240ead2f568de2e9f"),
        "windows_386": ("go1.10.6.windows-386.zip", "2f3ded109a37d53bd8600fa23c07d9abea41fb30a5f5954bbc97e9c57d8e0ce0"),
        "windows_amd64": ("go1.10.6.windows-amd64.zip", "fc57f16c23b7fb41b664f549ff2ed6cca340555e374c5ff52fa296cd3f228f32"),
    },
    "1.10.5": {
        "darwin_amd64": ("go1.10.5.darwin-amd64.tar.gz", "36873d9935f7f3519da11c9e928b66c94ccbf71c37df71b7635e804a226ae631"),
        "freebsd_386": ("go1.10.5.freebsd-386.tar.gz", "6533503d07f1f966966d5342584eca036aea72339af6da3b2db74bee94df8ac1"),
        "freebsd_amd64": ("go1.10.5.freebsd-amd64.tar.gz", "a742a8a2feec059ee32d79c9d72a11c87857619eb6d4fa7910c62a49901142c4"),
        "linux_386": ("go1.10.5.linux-386.tar.gz", "bc1bd42405a551ba7ac86b79b9d23a5635f21de53caf684acd8bf5dfee8bef5d"),
        "linux_amd64": ("go1.10.5.linux-amd64.tar.gz", "a035d9beda8341b645d3f45a1b620cf2d8fb0c5eb409be36b389c0fd384ecc3a"),
        "linux_arm64": ("go1.10.5.linux-arm64.tar.gz", "b4c16fcee18bc79de2fa4776c8d0f9bc164ddfc32101e96fe1da83ebe881e3df"),
        "linux_arm": ("go1.10.5.linux-armv6l.tar.gz", "1d864a6d0ec599de9112c8354dcaaa886b4df928757966939402598e9bd9c238"),
        "linux_ppc64le": ("go1.10.5.linux-ppc64le.tar.gz", "8fc13736d383312710249b24adf05af59ff14dacb73d9bd715ff463bc89c5c5f"),
        "linux_s390x": ("go1.10.5.linux-s390x.tar.gz", "e90269495fab7ef99aea6937caf7a049896b2dc7b181456f80a506e69a8b57fc"),
        "windows_386": ("go1.10.5.windows-386.zip", "e936532cc0d3ea9470129ba6df3714924fbc709a9441209a8154503cf16823f2"),
        "windows_amd64": ("go1.10.5.windows-amd64.zip", "d88a32eb4d1fc3b11253c9daa2ef397c8700f3ba493b41324b152e6cda44d2b4"),
    },
    "1.10.4": {
        "darwin_amd64": ("go1.10.4.darwin-amd64.tar.gz", "2ba324f01de2b2ece0376f6d696570a4c5c13db67d00aadfd612adc56feff587"),
        "freebsd_386": ("go1.10.4.freebsd-386.tar.gz", "d2d375daf6352e7b2d4f0dc8a90d1dbc463b955221b9d87fb1fbde805c979bb2"),
        "freebsd_amd64": ("go1.10.4.freebsd-amd64.tar.gz", "ad2fbf6ab2d1754f4ae5d8f6488bdcc6cc48dd15cac29207f38f7cbf0978ed17"),
        "linux_386": ("go1.10.4.linux-386.tar.gz", "771f48e55776d4abc9c2a74907457066c7c282ac05fa01cf5ff4422ced76d2ee"),
        "linux_amd64": ("go1.10.4.linux-amd64.tar.gz", "fa04efdb17a275a0c6e137f969a1c4eb878939e91e1da16060ce42f02c2ec5ec"),
        "linux_arm64": ("go1.10.4.linux-arm64.tar.gz", "2e0f9e99aeefaabba280b2bf85db0336da122accde73603159b3d72d0b2bd512"),
        "linux_arm": ("go1.10.4.linux-armv6l.tar.gz", "4e1e80bd98f3598c0c48ba0c189c836d01b602bfc769b827a4bfed01d2c14b21"),
        "linux_ppc64le": ("go1.10.4.linux-ppc64le.tar.gz", "1cfc147357c0be91a988998046997c5f30b20c6baaeb6cd5774717714db76093"),
        "linux_s390x": ("go1.10.4.linux-s390x.tar.gz", "5593d770d6544090c1bb20d57bb34c743131470695e195fbe5352bf056927a35"),
        "windows_386": ("go1.10.4.windows-386.zip", "407e5619048c427de4a65b26edb17d54c220f8c30ebd358961b1785a38394ec9"),
        "windows_amd64": ("go1.10.4.windows-amd64.zip", "5499aa98399664df8dc1da5c3aaaed14b3130b79c713b5677a0ee9e93854476c"),
    },
    "1.10.3": {
        "darwin_amd64": ("go1.10.3.darwin-amd64.tar.gz", "131fd430350a3134d352ee75c5ca456cdf4443e492d0527a9651c7c04e2b458d"),
        "freebsd_386": ("go1.10.3.freebsd-386.tar.gz", "92a28ccd8caa173295490dfd3f1d10f3bc7eaf0953bf099631bc6c57a5842704"),
        "freebsd_amd64": ("go1.10.3.freebsd-amd64.tar.gz", "231d9e6f3b5acee1193cd18b98c89f1a51570fbc8ba7c6c6b67a7f7ff2985e2b"),
        "linux_386": ("go1.10.3.linux-386.tar.gz", "3d5fe1932c904a01acb13dae07a5835bffafef38bef9e5a05450c52948ebdeb4"),
        "linux_amd64": ("go1.10.3.linux-amd64.tar.gz", "fa1b0e45d3b647c252f51f5e1204aba049cde4af177ef9f2181f43004f901035"),
        "linux_arm64": ("go1.10.3.linux-arm64.tar.gz", "355128a05b456c9e68792143801ad18e0431510a53857f640f7b30ba92624ed2"),
        "linux_arm": ("go1.10.3.linux-armv6l.tar.gz", "d3df3fa3d153e81041af24f31a82f86a21cb7b92c1b5552fb621bad0320f06b6"),
        "linux_ppc64le": ("go1.10.3.linux-ppc64le.tar.gz", "f3640b2f0990a9617c937775f669ee18f10a82e424e5f87a8ce794a6407b8347"),
        "linux_s390x": ("go1.10.3.linux-s390x.tar.gz", "34385f64651f82fbc11dc43bdc410c2abda237bdef87f3a430d35a508ec3ce0d"),
        "windows_386": ("go1.10.3.windows-386.zip", "89696a29bdf808fa9861216a21824ae8eb2e750a54b1424ce7f2a177e5cd1466"),
        "windows_amd64": ("go1.10.3.windows-amd64.zip", "a3f19d4fc0f4b45836b349503e347e64e31ab830dedac2fc9c390836d4418edb"),
    },
    "1.10.2": {
        "darwin_amd64": ("go1.10.2.darwin-amd64.tar.gz", "360ad908840217ee1b2a0b4654666b9abb3a12c8593405ba88ab9bba6e64eeda"),
        "freebsd_386": ("go1.10.2.freebsd-386.tar.gz", "f272774839a95041cf8874171ef6a8c6692e8784544ca05abbb29c66643d24a9"),
        "freebsd_amd64": ("go1.10.2.freebsd-amd64.tar.gz", "6174ff4c2da7ebb064e7f2b28419d2cd5d3f7de34bec9e42d3716bdb190c9955"),
        "linux_386": ("go1.10.2.linux-386.tar.gz", "ea4caddf76b86ed5d101a61bc9a273be5b24d81f0567270bb4d5beaaded9b567"),
        "linux_amd64": ("go1.10.2.linux-amd64.tar.gz", "4b677d698c65370afa33757b6954ade60347aaca310ea92a63ed717d7cb0c2ff"),
        "linux_arm64": ("go1.10.2.linux-arm64.tar.gz", "d6af66c71b12d63c754d5bf49c3007dc1c9821eb1a945118bfd5a539a327c4c8"),
        "linux_arm": ("go1.10.2.linux-armv6l.tar.gz", "529a16b531d4561572db6ba9d357215b58a1953437a63e76dc0c597be9e25dd2"),
        "linux_ppc64le": ("go1.10.2.linux-ppc64le.tar.gz", "f0748502c90e9784b6368937f1d157913d18acdae72ac75add50e5c0c9efc85c"),
        "linux_s390x": ("go1.10.2.linux-s390x.tar.gz", "2266b7ebdbca13c21a1f6039c9f6887cd2c01617d1e2716ff4595307a0da1d46"),
        "windows_386": ("go1.10.2.windows-386.zip", "0bb12875044674d632d1f1b2f53cf33510a6df914178fe672f3f70f6f6cdf80d"),
        "windows_amd64": ("go1.10.2.windows-amd64.zip", "0fb4a893796e8151c0b8d0a3da4ed8cbb22bf6d98a3c29c915be4d7083f146ee"),
    },
    "1.10.1": {
        "darwin_amd64": ("go1.10.1.darwin-amd64.tar.gz", "0a5bbcbbb0d150338ba346151d2864fd326873beaedf964e2057008c8a4dc557"),
        "linux_386": ("go1.10.1.linux-386.tar.gz", "acbe19d56123549faf747b4f61b730008b185a0e2145d220527d2383627dfe69"),
        "linux_amd64": ("go1.10.1.linux-amd64.tar.gz", "72d820dec546752e5a8303b33b009079c15c2390ce76d67cf514991646c6127b"),
        "linux_arm": ("go1.10.1.linux-armv6l.tar.gz", "feca4e920d5ca25001dc0823390df79bc7ea5b5b8c03483e5a2c54f164654936"),
        "windows_386": ("go1.10.1.windows-386.zip", "2f09edd066cc929bb362262afab27609e8d4b96f7dfd3f3844238e3214db9b8a"),
        "windows_amd64": ("go1.10.1.windows-amd64.zip", "17f7664131202b469f4264161ff3cd0796e8398249d2b646bbe4990301afc678"),
        "freebsd_386": ("go1.10.1.freebsd-386.tar.gz", "3e7f0967348d554ebe385f2372411ecfdbdc3074c8ff3ccb9f2910a765c4e472"),
        "freebsd_amd64": ("go1.10.1.freebsd-amd64.tar.gz", "41f57f91363c81523ec23d4a25f0ba92bd66a8c1a35b6df82491a8413bd2cd62"),
        "linux_arm64": ("go1.10.1.linux-arm64.tar.gz", "1e07a159414b5090d31166d1a06ee501762076ef21140dcd54cdcbe4e68a9c9b"),
        "linux_ppc64le": ("go1.10.1.linux-ppc64le.tar.gz", "91d0026bbed601c4aad332473ed02f9a460b31437cbc6f2a37a88c0376fc3a65"),
        "linux_s390x": ("go1.10.1.linux-s390x.tar.gz", "e211a5abdacf843e16ac33a309d554403beb63959f96f9db70051f303035434b"),
    },
    "1.10": {
        "darwin_amd64": ("go1.10.darwin-amd64.tar.gz", "511a4799e8d64cda3352bb7fe72e359689ea6ef0455329cda6b6e1f3137326c1"),
        "linux_386": ("go1.10.linux-386.tar.gz", "2d26a9f41fd80eeb445cc454c2ba6b3d0db2fc732c53d7d0427a9f605bfc55a1"),
        "linux_amd64": ("go1.10.linux-amd64.tar.gz", "b5a64335f1490277b585832d1f6c7f8c6c11206cba5cd3f771dcb87b98ad1a33"),
        "linux_arm": ("go1.10.linux-armv6l.tar.gz", "6ff665a9ab61240cf9f11a07e03e6819e452a618a32ea05bbb2c80182f838f4f"),
        "windows_386": ("go1.10.windows-386.zip", "83edd9e52ce6d1c8f911e7bbf6f0a73952c613b4bf66438ceb1507f892240f11"),
        "windows_amd64": ("go1.10.windows-amd64.zip", "210b223031c254a6eb8fa138c3782b23af710a9959d64b551fa81edd762ea167"),
        "freebsd_386": ("go1.10.freebsd-386.tar.gz", "d1e84cc46fa7290a6849c794785d629239f07c6f3e565616fa5421dd51344211"),
        "freebsd_amd64": ("go1.10.freebsd-amd64.tar.gz", "9ecc9dd288e9727b9ed250d5adbcf21073c038391e8d96aff46c20800be317c3"),
        "linux_arm64": ("go1.10.linux-arm64.tar.gz", "efb47e5c0e020b180291379ab625c6ec1c2e9e9b289336bc7169e6aa1da43fd8"),
        "linux_ppc64le": ("go1.10.linux-ppc64le.tar.gz", "a1e22e2fbcb3e551e0bf59d0f8aeb4b3f2df86714f09d2acd260c6597c43beee"),
        "linux_s390x": ("go1.10.linux-s390x.tar.gz", "71cde197e50afe17f097f81153edb450f880267699f22453272d184e0f4681d7"),
    },
    "1.9.7": {
        "darwin_amd64": ("go1.9.7.darwin-amd64.tar.gz", "3f4f84406dcada4eec785dbc967747f61c1f1b4e36d7545161e282259e9b215f"),
        "freebsd_386": ("go1.9.7.freebsd-386.tar.gz", "9e7e42975747c80aa5efe10d9cbe258669b9f5ea7e647919ba786a0f75627bbe"),
        "freebsd_amd64": ("go1.9.7.freebsd-amd64.tar.gz", "19b2bd6b83d806602216e2cacc27e40e97b6026bde0ec18cfb990bd9f2932708"),
        "linux_386": ("go1.9.7.linux-386.tar.gz", "c689fdb0b4f4530e48b44a3e591e53660fcbc97c3757ff9c3028adadabcf8378"),
        "linux_amd64": ("go1.9.7.linux-amd64.tar.gz", "88573008f4f6233b81f81d8ccf92234b4f67238df0f0ab173d75a302a1f3d6ee"),
        "linux_arm64": ("go1.9.7.linux-arm64.tar.gz", "68f48c29f93e4c69bbbdb335f473d666b9f8791643f4003ef45283a968b41f86"),
        "linux_arm": ("go1.9.7.linux-armv6l.tar.gz", "83b165d617807d636d2cfe07f34920ab6e5374a07ab02d60edcaec008de608ee"),
        "linux_ppc64le": ("go1.9.7.linux-ppc64le.tar.gz", "66cc2b9d591c8ef5adc4c4454f871546b0bab6be1dcbd151c2881729884fbbdd"),
        "linux_s390x": ("go1.9.7.linux-s390x.tar.gz", "7148ba7bc6f40b342d35a28b0cc43dd8f2b2acd7fb3e8891bc95b0f783bc8c9f"),
        "windows_386": ("go1.9.7.windows-386.zip", "0748a66f221f7608d2a6e52dda93bccb5a2d4dd5d8458de481b7f88972558c3c"),
        "windows_amd64": ("go1.9.7.windows-amd64.zip", "8db4b21916a3bc79f48d0611202ee5814c82f671b36d5d2efcb446879456cd28"),
    },
    "1.9.6": {
        "darwin_amd64": ("go1.9.6.darwin-amd64.tar.gz", "3de992c35021963af33029b7c0703bf25d1a3bb9236d117ebde09a9e12dfe715"),
        "freebsd_386": ("go1.9.6.freebsd-386.tar.gz", "e038805a0211dff4935b9ec325a888aa70ab6dc655a2252ae93d8fbd6eb23413"),
        "freebsd_amd64": ("go1.9.6.freebsd-amd64.tar.gz", "d557b31eec03addeede54d007240a3d66d1f439fbf3f0666203fc3ef2e2cfe59"),
        "linux_386": ("go1.9.6.linux-386.tar.gz", "de65e35d7e540578e78a3c6917b9e9033b55617ef894a1de1a6a6da5a1b948dd"),
        "linux_amd64": ("go1.9.6.linux-amd64.tar.gz", "d1eb07f99ac06906225ac2b296503f06cc257b472e7d7817b8f822fe3766ebfe"),
        "linux_arm64": ("go1.9.6.linux-arm64.tar.gz", "8596d64b9f582d6209c04513824e428d1c356276180d2089d4dfcf4c7cf8a6cc"),
        "linux_arm": ("go1.9.6.linux-armv6l.tar.gz", "73e56ec4408650d9fda0be8282a9ad49c51ad17929b4d20c04cea07249726bd8"),
        "linux_ppc64le": ("go1.9.6.linux-ppc64le.tar.gz", "b1203546c68e3be7b5e36a5cfb6ff5ef94bd476f5423035bc7e65255858741ff"),
        "linux_s390x": ("go1.9.6.linux-s390x.tar.gz", "2baa6e48eedb8ec7e2a4d2454cdf05d1f46d5a07ff2f03cab5b7b8eadef7e112"),
        "windows_386": ("go1.9.6.windows-386.zip", "1ec01c451f13127bb592b74b8d3e5a9fa1a24e48e9172cda783f0cdda6434904"),
        "windows_amd64": ("go1.9.6.windows-amd64.zip", "0b3a31eb7a46ef3976098cb92fde63c0871dceced91b0a3187953456f8eb8d6e"),
    },
    "1.9.5": {
        "darwin_amd64": ("go1.9.5.darwin-amd64.tar.gz", "2300c620a307bdee08670a9190e0916337514fd0bec3ea19115329d18c49b586"),
        "linux_386": ("go1.9.5.linux-386.tar.gz", "52e0e3421ac4d9b8d8c89121ea93e5e3180a26679a8ea64ecbeb3657251634a3"),
        "linux_amd64": ("go1.9.5.linux-amd64.tar.gz", "d21bdabf4272c2248c41b45cec606844bdc5c7c04240899bde36c01a28c51ee7"),
        "linux_arm": ("go1.9.5.linux-armv6l.tar.gz", "e9b6f0cbd95ff3077ddeaec1958be77d9675f0cf5652a67152d28d84707a4e9e"),
        "windows_386": ("go1.9.5.windows-386.zip", "c29ea03496a5d61ddcc811110b3d6b8f774e89b19a6dc3839f2d2f82e3789635"),
        "windows_amd64": ("go1.9.5.windows-amd64.zip", "6c3ef0e069c0edb0b5e8575f0efca806f69354a7b808f9846b89046f46a260c2"),
        "freebsd_386": ("go1.9.5.freebsd-386.tar.gz", "9f8f7ad7249b26dc7bc8fdd335d89c1cae3de3232ac6c5053171eba9b5923a0a"),
        "freebsd_amd64": ("go1.9.5.freebsd-amd64.tar.gz", "141728cdde1adcb097f252d51aebbcff5e45e30f56bf066fcb158474c293c388"),
        "linux_arm64": ("go1.9.5.linux-arm64.tar.gz", "d0bb265559cd8613882e6bbd197a80ed7090684117c6fc6900aa58dea2463715"),
        "linux_ppc64le": ("go1.9.5.linux-ppc64le.tar.gz", "dfd928ab818f72b801273c669d86e6c05626f2c2addc1c7178bb715fc608daf2"),
        "linux_s390x": ("go1.9.5.linux-s390x.tar.gz", "82c86885c8cc4d62ff81f828529c72cacd0ca8b02d442dc659858c6738363775"),
    },
    "1.9.4": {
        "darwin_amd64": ("go1.9.4.darwin-amd64.tar.gz", "0e694bfa289453ecb056cc70456e42fa331408cfa6cc985a14edb01d8b4fec51"),
        "linux_386": ("go1.9.4.linux-386.tar.gz", "d440aee90dad851630559bcee2b767b543ce7e54f45162908f3e12c3489888ab"),
        "linux_amd64": ("go1.9.4.linux-amd64.tar.gz", "15b0937615809f87321a457bb1265f946f9f6e736c563d6c5e0bd2c22e44f779"),
        "linux_arm": ("go1.9.4.linux-armv6l.tar.gz", "3c8cf3f79754a9fd6b33e2d8f930ee37d488328d460065992c72bc41c7b41a49"),
        "windows_386": ("go1.9.4.windows-386.zip", "ad5905b211e543a1e59758acd4c6f30d446e5af8c4ea997961caf1ef02cdd56d"),
        "windows_amd64": ("go1.9.4.windows-amd64.zip", "880e011ac6f4a509308a62ec6d963dd9d561d0cdc705e93d81c750d7f1c696f4"),
        "freebsd_386": ("go1.9.4.freebsd-386.tar.gz", "ca5874943d1fe5f9698594f65bb4d82f9e0f7ca3a09b1c306819df6f7349fd17"),
        "freebsd_amd64": ("go1.9.4.freebsd-amd64.tar.gz", "d91c3dc997358af47fc0070c09586b3e7aa47282a75169fa6b00d9ac3ca61d89"),
        "linux_arm64": ("go1.9.4.linux-arm64.tar.gz", "41a71231e99ccc9989867dce2fcb697921a68ede0bd06fc288ab6c2f56be8864"),
        "linux_ppc64le": ("go1.9.4.linux-ppc64le.tar.gz", "8b25484a7b4b6db81b3556319acf9993cc5c82048c7f381507018cb7c35e746b"),
        "linux_s390x": ("go1.9.4.linux-s390x.tar.gz", "129f23b13483b1a7ccef49bc4319daf25e1b306f805780fdb5526142985edb68"),
    },
    "1.9.3": {
        "darwin_amd64": ("go1.9.3.darwin-amd64.tar.gz", "f84b39c2ed7df0c2f1648e2b90b2198a6783db56b53700dabfa58afd6335d324"),
        "linux_386": ("go1.9.3.linux-386.tar.gz", "bc0782ac8116b2244dfe2a04972bbbcd7f1c2da455a768ab47b32864bcd0d49d"),
        "linux_amd64": ("go1.9.3.linux-amd64.tar.gz", "a4da5f4c07dfda8194c4621611aeb7ceaab98af0b38bfb29e1be2ebb04c3556c"),
        "linux_arm": ("go1.9.3.linux-armv6l.tar.gz", "926d6cd6c21ef3419dca2e5da8d4b74b99592ab1feb5a62a4da244e6333189d2"),
        "windows_386": ("go1.9.3.windows-386.zip", "cab7d4e008adefed322d36dee87a4c1775ab60b25ce587a2b55d90c75d0bafbc"),
        "windows_amd64": ("go1.9.3.windows-amd64.zip", "4eee59bb5b70abc357aebd0c54f75e46322eb8b58bbdabc026fdd35834d65e1e"),
        "freebsd_386": ("go1.9.3.freebsd-386.tar.gz", "a755739e3be0415344d62ea3b168bdcc9a54f7862ac15832684ff2d3e8127a03"),
        "freebsd_amd64": ("go1.9.3.freebsd-amd64.tar.gz", "f95066089a88749c45fae798422d04e254fe3b622ff030d12bdf333402b186ec"),
        "linux_arm64": ("go1.9.3.linux-arm64.tar.gz", "065d79964023ccb996e9dbfbf94fc6969d2483fbdeeae6d813f514c5afcd98d9"),
        "linux_ppc64le": ("go1.9.3.linux-ppc64le.tar.gz", "c802194b1af0cd904689923d6d32f3ed68f9d5f81a3e4a82406d9ce9be163681"),
        "linux_s390x": ("go1.9.3.linux-s390x.tar.gz", "85e9a257664f84154e583e0877240822bb2fe4308209f5ff57d80d16e2fb95c5"),
    },
    "1.9.2": {
        "darwin_amd64": ("go1.9.2.darwin-amd64.tar.gz", "73fd5840d55f5566d8db6c0ffdd187577e8ebe650c783f68bd27cbf95bde6743"),
        "linux_386": ("go1.9.2.linux-386.tar.gz", "574b2c4b1a248e58ef7d1f825beda15429610a2316d9cbd3096d8d3fa8c0bc1a"),
        "linux_amd64": ("go1.9.2.linux-amd64.tar.gz", "de874549d9a8d8d8062be05808509c09a88a248e77ec14eb77453530829ac02b"),
        "linux_arm": ("go1.9.2.linux-armv6l.tar.gz", "8a6758c8d390e28ef2bcea511f62dcb43056f38c1addc06a8bc996741987e7bb"),
        "windows_386": ("go1.9.2.windows-386.zip", "35d3be5d7b97c6d11ffb76c1b19e20a824e427805ee918e82c08a2e5793eda20"),
        "windows_amd64": ("go1.9.2.windows-amd64.zip", "682ec3626a9c45b657c2456e35cadad119057408d37f334c6c24d88389c2164c"),
        "freebsd_386": ("go1.9.2.freebsd-386.tar.gz", "809dcb0a8457c8d0abf954f20311a1ee353486d0ae3f921e9478189721d37677"),
        "freebsd_amd64": ("go1.9.2.freebsd-amd64.tar.gz", "8be985c3e251c8e007fa6ecd0189bc53e65cc519f4464ddf19fa11f7ed251134"),
        "linux_arm64": ("go1.9.2.linux-arm64.tar.gz", "0016ac65ad8340c84f51bc11dbb24ee8265b0a4597dbfdf8d91776fc187456fa"),
        "linux_ppc64le": ("go1.9.2.linux-ppc64le.tar.gz", "adb440b2b6ae9e448c253a20836d8e8aa4236f731d87717d9c7b241998dc7f9d"),
        "linux_s390x": ("go1.9.2.linux-s390x.tar.gz", "a7137b4fbdec126823a12a4b696eeee2f04ec616e9fb8a54654c51d5884c1345"),
    },
    "1.9.1": {
        "darwin_amd64": ("go1.9.1.darwin-amd64.tar.gz", "59bc6deee2969dddc4490b684b15f63058177f5c7e27134c060288b7d76faab0"),
        "linux_386": ("go1.9.1.linux-386.tar.gz", "2cea1ce9325cb40839601b566bc02b11c92b2942c21110b1b254c7e72e5581e7"),
        "linux_amd64": ("go1.9.1.linux-amd64.tar.gz", "07d81c6b6b4c2dcf1b5ef7c27aaebd3691cdb40548500941f92b221147c5d9c7"),
        "linux_arm": ("go1.9.1.linux-armv6l.tar.gz", "65a0495a50c7c240a6487b1170939586332f6c8f3526abdbb9140935b3cff14c"),
        "windows_386": ("go1.9.1.windows-386.zip", "ea9c79c9e6214c9a78a107ef5a7bff775a281bffe8c2d50afa66d2d33998078a"),
        "windows_amd64": ("go1.9.1.windows-amd64.zip", "8dc72a3881388e4e560c2e45f6be59860b623ad418e7da94e80fee012221cc81"),
        "freebsd_386": ("go1.9.1.freebsd-386.tar.gz", "0da7ad96606a8ceea85652eb20816077769d51de9219d85b9b224a3390070c50"),
        "freebsd_amd64": ("go1.9.1.freebsd-amd64.tar.gz", "c4eeacbb94821c5f252897a4d49c78293eaa97b29652d789dce9e79bc6aa6163"),
        "linux_arm64": ("go1.9.1.linux-arm64.tar.gz", "d31ecae36efea5197af271ccce86ccc2baf10d2e04f20d0fb75556ecf0614dad"),
        "linux_ppc64le": ("go1.9.1.linux-ppc64le.tar.gz", "de57b6439ce9d4dd8b528599317a35fa1e09d6aa93b0a80e3945018658d963b8"),
        "linux_s390x": ("go1.9.1.linux-s390x.tar.gz", "9adf03574549db82a72e0d721ef2178ec5e51d1ce4f309b271a2bca4dcf206f6"),
    },
    "1.9": {
        "darwin_amd64": ("go1.9.darwin-amd64.tar.gz", "c2df361ec6c26fcf20d5569496182cb20728caa4d351bc430b2f0f1212cca3e0"),
        "linux_386": ("go1.9.linux-386.tar.gz", "7cccff99dacf59162cd67f5b11070d667691397fd421b0a9ad287da019debc4f"),
        "linux_amd64": ("go1.9.linux-amd64.tar.gz", "d70eadefce8e160638a9a6db97f7192d8463069ab33138893ad3bf31b0650a79"),
        "linux_arm": ("go1.9.linux-armv6l.tar.gz", "f52ca5933f7a8de2daf7a3172b0406353622c6a39e67dd08bbbeb84c6496f487"),
        "windows_386": ("go1.9.windows-386.zip", "ecfe6f5be56acedc56cd9ff735f239a12a7c94f40b0ea9753bbfd17396f5e4b9"),
        "windows_amd64": ("go1.9.windows-amd64.zip", "874b144b994643cff1d3f5875369d65c01c216bb23b8edddf608facc43966c8b"),
        "freebsd_386": ("go1.9.freebsd-386.tar.gz", "9e415e340eaea526170b0fd59aa55939ff4f76c126193002971e8c6799e2ed3a"),
        "freebsd_amd64": ("go1.9.freebsd-amd64.tar.gz", "ba54efb2223fb4145604dcaf8605d519467f418ab02c081d3cd0632b6b43b6e7"),
        "linux_ppc64le": ("go1.9.linux-ppc64le.tar.gz", "10b66dae326b32a56d4c295747df564616ec46ed0079553e88e39d4f1b2ae985"),
        "linux_arm64": ("go1.9.linux-arm64.tar.gz", "0958dcf454f7f26d7acc1a4ddc34220d499df845bc2051c14ff8efdf1e3c29a6"),
        "linux_s390x": ("go1.9.linux-s390x.tar.gz", "e06231e4918528e2eba1d3cff9bc4310b777971e5d8985f9772c6018694a3af8"),
    },
}

_label_prefix = "@io_bazel_rules_go//go/toolchain:"

def go_register_toolchains(go_version = DEFAULT_VERSION, nogo = None):
    """See /go/toolchains.rst#go-register-toolchains for full documentation."""
    if "go_sdk" not in native.existing_rules():
        if go_version in SDK_REPOSITORIES:
            if not versions.is_at_least(MIN_SUPPORTED_VERSION, go_version):
                print("DEPRECATED: go_register_toolchains: support for Go versions before {} will be removed soon".format(MIN_SUPPORTED_VERSION))
            go_download_sdk(
                name = "go_sdk",
                sdks = SDK_REPOSITORIES[go_version],
            )
        elif go_version == "host":
            go_host_sdk(
                name = "go_sdk",
            )
        else:
            fail("Unknown go version {}".format(go_version))

    if nogo:
        # Override default definition in go_rules_dependencies().
        go_register_nogo(
            name = "io_bazel_rules_nogo",
            nogo = nogo,
        )

def declare_constraints():
    for goos, constraint in GOOS.items():
        if constraint:
            native.alias(
                name = goos,
                actual = constraint,
            )
        else:
            native.constraint_value(
                name = goos,
                constraint_setting = "@bazel_tools//platforms:os",
            )
    for goarch, constraint in GOARCH.items():
        if constraint:
            native.alias(
                name = goarch,
                actual = constraint,
            )
        else:
            native.constraint_value(
                name = goarch,
                constraint_setting = "@bazel_tools//platforms:cpu",
            )
    for goos, goarch in GOOS_GOARCH:
        native.platform(
            name = goos + "_" + goarch,
            constraint_values = [
                ":" + goos,
                ":" + goarch,
            ],
        )

def declare_toolchains(host, sdk):
    # Use the final dictionaries to create all the toolchains
    for toolchain in generate_toolchains(host, sdk):
        go_toolchain(**toolchain)
