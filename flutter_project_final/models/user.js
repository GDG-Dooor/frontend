const mongoose = require('mongoose');
const { Schema } = mongoose;

const userSchema = new Schema({
  email: { 
    type: String, 
    required: true,
    trim: true,  // 공백 제거
    lowercase: true  // 소문자로 저장
  },
  password: {
    type: String,
    required: true
  }
});

module.exports = mongoose.model('User', userSchema);