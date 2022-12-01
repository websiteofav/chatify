enum EmailSignupResults {
  signupCompleted,
  emailAlreadyPresent,
  problemInSignup,
}

enum EmailLoginResults {
  loginCompleted,
  emailAndPasswordInvalid,
  emailNotVerified,
  genericeError,
}

enum GoogleSigninResults {
  loginCompleted,
  loginFailure,
}

enum UserDetailsResults {
  userFound,
  userNotFound,
  genericeError,
}

enum UserDetailsAddedResults {
  detailAdded,
  detailsNotAdded,
}

enum UserDetailsRecordsResults {
  userNotFound,
  detailFound,
  detailsNotFound,
  genericeError,
}

enum UserActivityMediaTypes {
  text,
  image,
}
