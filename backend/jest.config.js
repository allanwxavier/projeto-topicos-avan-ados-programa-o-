/** @type {import("ts-jest").JestConfigWithTsJest} */
module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  rootDir: "./",
  transform: {
    "^.+\\.tsx?$": [
      "ts-jest",
      {
        tsconfig: "tsconfig.jest.json",
      },
    ],
  },
  testMatch: ["<rootDir>/tests/**/*.test.ts", "<rootDir>/tests/**/*.spec.ts"],
  
  // Cobertura de código para o SonarCloud
  collectCoverage: true,
  coverageDirectory: "<rootDir>/coverage",
  coverageReporters: ["text", "lcov", "clover"],
  collectCoverageFrom: [
    "<rootDir>/src/**/*.ts",
    "!<rootDir>/src/server.ts",
    "!<rootDir>/src/config/**",
    "!<rootDir>/src/middlewares/**"
  ]
};