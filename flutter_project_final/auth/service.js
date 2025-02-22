// ... existing code ...
// 회원가입 시 비밀번호 해시화
const hashedPassword = await bcrypt.hash(password, 10);
await User.create({
  email,
  password: hashedPassword  // 해시화된 비밀번호 저장
});

// 로그인 시 비밀번호 비교
const isMatch = await bcrypt.compare(password, user.password);
// ... existing code ...