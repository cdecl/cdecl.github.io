---
title: CryotoPP Example

toc: true
toc_sticky: true

categories:
  - dev
tags:
  - cryptopp
  - crypto++
  - aes
  - cbc
  - crypto
---


## CryptoPP
- <https://www.cryptopp.com/>{:target="_blank"}
- [Crypto++ 사용하기, 예제](https://cdecl.tistory.com/277){:target="_blank"}
- [암호화 지식 (개발자)](/dev/crypto-for-develop/){:target="_blank"}

> 기존 작성한 내용(5.6 버전)의 최신화(8.5 버전) : 빌드 이슈 

### Package 설치 
- vcpkg 사용 : 8.5.0

```
$ ./vcpkg install cryptopp
Computing installation plan...
The following packages will be built and installed:
    cryptopp[core]:arm64-osx -> 8.5.0
...
The package cryptopp:arm64-osx provides CMake targets:

    find_package(cryptopp CONFIG REQUIRED)
    target_link_libraries(main PRIVATE cryptopp-static)
```

- CMakeLists.txt

```
cmake_minimum_required(VERSION 3.11)
project(main)
set(CMAKE_CXX_STANDARD 17)

add_executable(main main.cpp)
target_compile_options(main PRIVATE -Wall -O2)

find_package(cryptopp CONFIG REQUIRED)
target_link_libraries(main PRIVATE cryptopp-static)
```

#### Build 
```
$ mkdir build && cd build
$ cmake .. -DCMAKE_TOOLCHAIN_FILE=<PATH>/vcpkg/scripts/buildsystems/vcpkg.cmake

$ build 
```

---
### Example 
- 기본 Flow

```
- Encryption : StringSource -> StreamTransformationFilter(Encryptor) -> Base64Encoder(StringSink)
- Decryption : StringSource -> Base64Decoder -> StreamTransformationFilter(Decryptor, StringSink)
```

#### 과거 버전과의 이슈 
- `std::byte`의 표준화 이전에 작성된 라이브러리라, byte 타입 충돌 
  - <https://www.cryptopp.com/wiki/Modes_of_Operation>{:target="_blank"}
  - KEY, IV 를 정의하기 위해 `CryptoPP::SecByteBlock` 타입 사용

```cpp
#include <iostream>
#include <algorithm>
using namespace std;

#include <cryptopp/cryptlib.h>
#include <cryptopp/base64.h>
#include <cryptopp/aes.h>
#include <cryptopp/seed.h>
#include <cryptopp/des.h>
#include <cryptopp/modes.h>
#include <cryptopp/filters.h>

template <class EncryptorType>
std::string Encrypt(EncryptorType &encryptor, const std::string &PlainText) 
{
	std::string CipherText;
	CryptoPP::StringSource(PlainText, true,
		new CryptoPP::StreamTransformationFilter(
			encryptor, new CryptoPP::Base64Encoder(new CryptoPP::StringSink(CipherText), false) /* default padding */
		)
	);
	return CipherText;
}

template <class DecryptorType>
std::string Decrypt(DecryptorType &decryptor, const std::string &EncText) 
{
	std::string PlainText;
	CryptoPP::StringSource(EncText, true,
		new CryptoPP::Base64Decoder(
			new CryptoPP::StreamTransformationFilter(
				decryptor, new CryptoPP::StringSink(PlainText)
			)
		)
	);
	return PlainText;
}

int main()
{
	using namespace std;
	using AES = CryptoPP::AES;

	CryptoPP::SecByteBlock KEY(AES::DEFAULT_KEYLENGTH);
	CryptoPP::SecByteBlock IV(AES::DEFAULT_KEYLENGTH);

	// 임의 값 초기화 
	for (auto &c : KEY) c = 0;
	for (auto &c : IV) c = 0;

	CryptoPP::CBC_Mode<AES>::Encryption Encryptor { KEY, KEY.size(), IV };
	CryptoPP::CBC_Mode<AES>::Decryption Decryptor { KEY, KEY.size(), IV };

	try {
		string sText = "Plain Text";
		string sEnc, sDec;

		sEnc = Encrypt(Encryptor, sText);
		cout << sText << " -> " << sEnc << endl;

		sDec = Decrypt(Decryptor, sEnc);
		cout << sEnc << " -> " << sDec << endl;	
	}
	catch (exception &ex) {
		cerr << ex.what() << endl;
	}

	return 0;
}
```

```sh
$ ./main
Plain Text -> MtiafY0csWZJZzsRNfE8cA==
MtiafY0csWZJZzsRNfE8cA== -> Plain Text
```