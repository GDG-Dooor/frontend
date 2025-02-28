const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;

// 인증 미들웨어
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(403).json({
      success: false,
      message: '인증 토큰이 필요합니다.'
    });
  }

  try {
    // 토큰 검증 로직
    // TODO: JWT 검증 등 실제 토큰 검증 로직 구현
    next();
  } catch (error) {
    return res.status(403).json({
      success: false,
      message: '유효하지 않은 토큰입니다.'
    });
  }
};

// 이미지 업로드를 위한 multer 설정
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/quest-verifications/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 20 * 1024 * 1024 // 20MB 제한
  },
  fileFilter: (req, file, cb) => {
    // 이미지 파일만 허용
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('이미지 파일만 업로드 가능합니다.'), false);
    }
  }
});

// 퀘스트 검증 API 핸들러
module.exports = [authenticateToken, async (req, res) => {
  try {
    // multer 미들웨어를 통한 파일 업로드 처리
    upload.single('image')(req, res, async (err) => {
      if (err) {
        return res.status(400).json({
          success: false,
          message: err.message || '파일 업로드 중 오류가 발생했습니다.'
        });
      }

      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: '이미지 파일이 필요합니다.'
        });
      }

      const questId = parseInt(req.query.questId);
      if (!questId) {
        // 업로드된 파일 삭제
        await fs.unlink(req.file.path);
        return res.status(400).json({
          success: false,
          message: '퀘스트 ID가 필요합니다.'
        });
      }

      try {
        // 퀘스트 ID에 따른 이미지 검증 로직
        const validationResult = await validateQuestImage(questId, req.file.path);
        
        // 검증 완료 후 업로드된 파일 삭제
        await fs.unlink(req.file.path);

        return res.status(200).json(validationResult);
      } catch (error) {
        // 오류 발생 시 업로드된 파일 삭제
        await fs.unlink(req.file.path);
        throw error;
      }
    });
  } catch (error) {
    console.error('퀘스트 검증 중 오류:', error);
    return res.status(500).json({
      success: false,
      message: '서버 오류가 발생했습니다.'
    });
  }
}];

// 퀘스트 이미지 검증 함수
async function validateQuestImage(questId, imagePath) {
  // TODO: 퀘스트 ID에 따른 실제 이미지 검증 로직 구현
  // 예시: 이미지 분석 API 사용, 객체 인식, OCR 등
  
  // 임시로 모든 이미지를 유효한 것으로 처리
  return true;
} 