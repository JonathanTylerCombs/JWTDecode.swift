import Quick
import Nimble
import JWTDecode
import Foundation

class JWTDecodeSpec: QuickSpec {

    override func spec() {
        describe("decode") {

            it("should tell a jwt is expired") {
                expect(expiredJWT().expired).to(beTruthy())
            }

            it("should tell a jwt is not expired") {
                expect(nonExpiredJWT().expired).to(beFalsy())
            }

            it("should tell a jwt is expired with a close enough timestamp") {
                expect(jwtThatExpiresAt(date: Date()).expired).to(beTruthy())
            }

            it("should obtain payload") {
                let jwt = jwt(withBody: ["sub": "myid", "name": "Shawarma Monk"])
                let payload = jwt.body as! [String: String]
                expect(payload).to(equal(["sub": "myid", "name": "Shawarma Monk"]))
            }

            it("should return original jwt string representation") {
                let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGkiLCJpc3MiOiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.sS84motSLj9HNTgrCPcAjgZIQ99jXNN7_W9fEIIfxz0"
                let jwt = try! decode(jwt: jwtString)
                expect(jwt.string).to(equal(jwtString))
            }

            it("should return expire date") {
                expect(expiredJWT().expiresAt).toNot(beNil())
            }

            it("should decode valid jwt") {
                let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjb20uc29td2hlcmUuZmFyLmJleW9uZDphcGkiLCJpc3MiOiJhdXRoMCIsInVzZXJfcm9sZSI6ImFkbWluIn0.sS84motSLj9HNTgrCPcAjgZIQ99jXNN7_W9fEIIfxz0"
                expect(try! decode(jwt: jwtString)).toNot(beNil())
            }

            it("should decode valid jwt with empty json body") {
                let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.Et9HFtf9R3GEMA0IICOfFMVXY7kkTX1wr4qCyhIf58U"
                expect(try! decode(jwt: jwtString)).toNot(beNil())
            }

            it("should raise exception with invalid base64 encoding") {
                let invalidChar = "%"
                let jwtString = "\(invalidChar).BODY.SIGNATURE"
                expect { try decode(jwt: jwtString) }
                    .to(throwError { (error: Error) in
                        expect(error).to(beDecodeErrorWithCode(.invalidBase64Url(invalidChar)))
                    })
            }

            it("should raise exception with invalid json in jwt") {
                let jwtString = "HEADER.BODY.SIGNATURE"
                expect { try decode(jwt: jwtString) }
                    .to(throwError { (error: Error) in
                        expect(error).to(beDecodeErrorWithCode(.invalidJSON("HEADER")))
                    })
            }

            it("should raise exception with missing parts") {
                let jwtString = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ"
                expect { try decode(jwt: jwtString) }
                    .to(throwError { (error: Error) in
                        expect(error).to(beDecodeErrorWithCode(.invalidPartCount(jwtString, 2)))
                    })
            }

        }

        describe("jwt parts") {
            let jwt = try! decode(jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzdWIifQ.xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7ZXm4QpVvXnY")

            it("should return header") {
                expect(jwt.header as? [String: String]).to(equal(["alg": "HS256", "typ": "JWT"]))
            }

            it("should return body") {
                expect(jwt.body as? [String: String]).to(equal(["sub": "sub"]))
            }

            it("should return signature") {
                expect(jwt.signature).to(equal("xXcD7WOvUDHJ94E6aVHYgXdsJHLl2oW7ZXm4QpVvXnY"))
            }
        }

        describe("claims") {
            var token: JWT!

            describe("expiresAt claim") {

                it("should handle expired jwt") {
                    token = expiredJWT()
                    expect(token.expiresAt).toNot(beNil())
                    expect(token.expired).to(beTruthy())
                }

                it("should handle non-expired jwt") {
                    token = nonExpiredJWT()
                    expect(token.expiresAt).toNot(beNil())
                    expect(token.expired).to(beFalsy())
                }

                it("should handle jwt without expiresAt claim") {
                    token = jwt(withBody: ["sub": UUID().uuidString])
                    expect(token.expiresAt).to(beNil())
                    expect(token.expired).to(beFalsy())
                }
            }

            describe("registered claims") {

                let jwt = try! decode(jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3NhbXBsZXMuYXV0aDAuY29tIiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vc2FtcGxlcy5hdXRoMC5jb20iLCJleHAiOjEzNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2fQ.LvF9wSheCB5xarpydmurWgi9NOZkdES5AbNb_UWk9Ew")


                it("should return issuer") {
                    expect(jwt.issuer).to(equal("https://samples.auth0.com"))
                }

                it("should return subject") {
                    expect(jwt.subject).to(equal("auth0|1010101010"))
                }

                it("should return single audience") {
                    expect(jwt.audience).to(equal(["https://samples.auth0.com"]))
                }

                context("multiple audiences") {

                    let jwt = try! decode(jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiaHR0cHM6Ly9zYW1wbGVzLmF1dGgwLmNvbSIsImh0dHBzOi8vYXBpLnNhbXBsZXMuYXV0aDAuY29tIl19.cfWFPuJbQ7NToa-BjHgHD1tHn3P2tOP5wTQaZc1qg6M")

                    it("should return all audiences") {
                        expect(jwt.audience).to(equal(["https://samples.auth0.com", "https://api.samples.auth0.com"]))
                    }
                }

                it("should return issued at") {
                    expect(jwt.issuedAt).to(equal(Date(timeIntervalSince1970: 1372638336)))
                }

                it("should return not before") {
                    expect(jwt.notBefore).to(equal(Date(timeIntervalSince1970: 1372638336)))
                }

                it("should return jwt id") {
                    expect(jwt.identifier).to(equal("qwerty123456"))
                }
            }

            describe("custom claim") {

                beforeEach {
                    token = jwt(withBody: ["sub": UUID().uuidString, "custom_string_claim": "Shawarma Friday!", "custom_integer_claim": 10, "custom_double_claim": 3.4, "custom_double_string_claim": "1.3", "custom_true_boolean_claim": true, "custom_false_boolean_claim": false])
                }

                it("should return claim by name") {
                    let claim = token.claim(name: "custom_string_claim")
                    expect(claim.rawValue).toNot(beNil())
                }

                it("should return string claim") {
                    let claim = token["custom_string_claim"]
                    expect(claim.string) == "Shawarma Friday!"
                    expect(claim.array) == ["Shawarma Friday!"]
                    expect(claim.integer).to(beNil())
                    expect(claim.double).to(beNil())
                    expect(claim.date).to(beNil())
                    expect(claim.boolean).to(beNil())
                }

                it("should return integer claim") {
                    let claim = token["custom_integer_claim"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer) == 10
                    expect(claim.double) == 10.0
                    expect(claim.date) == Date(timeIntervalSince1970: 10)
                    expect(claim.boolean).to(beNil())
                }

                it("should return double claim") {
                    let claim = token["custom_double_claim"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer) == 3
                    expect(claim.double) == 3.4
                    expect(claim.date) == Date(timeIntervalSince1970: 3.4)
                    expect(claim.boolean).to(beNil())
                }

                it("should return double as string claim") {
                    let claim = token["custom_double_string_claim"]
                    expect(claim.string) == "1.3"
                    expect(claim.array) == ["1.3"]
                    expect(claim.integer).to(beNil())
                    expect(claim.double) == 1.3
                    expect(claim.date) == Date(timeIntervalSince1970: 1.3)
                    expect(claim.boolean).to(beNil())
                }

                it("should return true boolean claim") {
                    let claim = token["custom_true_boolean_claim"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer).to(beNil())
                    expect(claim.double).to(beNil())
                    expect(claim.date).to(beNil())
                    expect(claim.boolean) == true
                }

                it("should return false boolean claim") {
                    let claim = token["custom_false_boolean_claim"]
                    expect(claim.string).to(beNil())
                    expect(claim.array).to(beNil())
                    expect(claim.integer).to(beNil())
                    expect(claim.double).to(beNil())
                    expect(claim.date).to(beNil())
                    expect(claim.boolean) == false
                }

                it("should return no value when claim is not present") {
                    let unknownClaim = token["missing_claim"]
                    expect(unknownClaim.array).to(beNil())
                    expect(unknownClaim.string).to(beNil())
                    expect(unknownClaim.integer).to(beNil())
                    expect(unknownClaim.double).to(beNil())
                    expect(unknownClaim.date).to(beNil())
                    expect(unknownClaim.boolean).to(beNil())
                }

                context("raw claim") {

                    var token: JWT!

                    beforeEach {
                        token = try! decode(jwt: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3NhbXBsZXMuYXV0aDAuY29tIiwic3ViIjoiYXV0aDB8MTAxMDEwMTAxMCIsImF1ZCI6Imh0dHBzOi8vc2FtcGxlcy5hdXRoMC5jb20iLCJleHAiOjEzNzI2NzQzMzYsImlhdCI6MTM3MjYzODMzNiwianRpIjoicXdlcnR5MTIzNDU2IiwibmJmIjoxMzcyNjM4MzM2LCJlbWFpbCI6InVzZXJAaG9zdC5jb20iLCJjdXN0b20iOlsxLDIsM119.JeMRyHLkcoiqGxd958B6PABKNvhOhIgw-kbjecmhR_E")
                    }

                    it("should return email") {
                        expect(token["email"].string) == "user@host.com"
                    }

                    it("should return array") {
                        expect(token["custom"].rawValue as? [Int]).toNot(beNil())
                    }

                }
            }
        }
    }
}

public func beDecodeErrorWithCode(_ code: DecodeError) -> Predicate<Error> {
     return Predicate<Error>.define("be decode error with code <\(code)>") { expression, failureMessage -> PredicateResult in
        guard let actual = try expression.evaluate() as? DecodeError else {
            return PredicateResult(status: .doesNotMatch, message: failureMessage)
        }
        return PredicateResult(bool: actual == code, message: failureMessage)
    }
}

extension DecodeError: Equatable {}

public func ==(lhs: DecodeError, rhs: DecodeError) -> Bool {
    return lhs.localizedDescription == rhs.localizedDescription && lhs.errorDescription == rhs.errorDescription
}