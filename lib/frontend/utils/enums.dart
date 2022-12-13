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

enum UserPartnersState {
  connect,
  pending,
  accept,
  connected,
}

enum OtherUserPartnersState {
  requestPending,
  requestRecieved,
  invitationPending,
  requestAccepted,
}

enum ChatMessageTypes {
  none,
  text,
  image,
  video,
  location,
  document,
  audio,
}
