import { body, param, validationResult } from 'express-validator';

// Helper function to handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      error: 'Validation failed',
      details: errors.array()
    });
  }
  next();
};

// ==================== TEAM VALIDATION ====================

export const validateTeamInput = [
  body('name').trim().notEmpty().withMessage('Team name is required').isLength({ min: 2, max: 100 }).withMessage('Team name must be between 2 and 100 characters'),

  body('description').optional().trim().isLength({ max: 500 }).withMessage('Description must not exceed 500 characters'),

  body('industry').optional().trim().isLength({ max: 100 }).withMessage('Industry must not exceed 100 characters'),

  body('size').optional().isIn(['1-10', '11-50', '51-100', '101-500', '500+']).withMessage('Invalid team size option'),

  body('type').optional().isIn(['company', 'agency', 'startup', 'non-profit', 'educational', 'personal']).withMessage('Invalid team type'),

  body('settings.isPublic').optional().isBoolean().withMessage('isPublic must be a boolean'),

  body('settings.allowPublicProjects').optional().isBoolean().withMessage('allowPublicProjects must be a boolean'),

  body('settings.requireApprovalForJoining').optional().isBoolean().withMessage('requireApprovalForJoining must be a boolean'),

  body('settings.allowMemberInvites').optional().isBoolean().withMessage('allowMemberInvites must be a boolean'),

  body('settings.defaultProjectTemplate').optional().isIn(['Kanban', 'Scrum', 'Blank Project', 'Project Management', 'Task Tracking']).withMessage('Invalid default project template'),

  body('settings.timezone')
    .optional()
    .trim()
    .matches(/^[A-Za-z_]+\/[A-Za-z_]+$/)
    .withMessage('Invalid timezone format'),

  body('settings.workingHours.start')
    .optional()
    .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Invalid start time format (HH:MM)'),

  body('settings.workingHours.end')
    .optional()
    .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/)
    .withMessage('Invalid end time format (HH:MM)'),

  body('memberLimit').optional().isInt({ min: 1, max: 1000 }).withMessage('Member limit must be between 1 and 1000'),

  handleValidationErrors
];

// ==================== INVITATION VALIDATION ====================

export const validateInviteInput = [
  body('email').isEmail().normalizeEmail().withMessage('Valid email is required'),

  body('role').optional().isIn(['admin', 'manager', 'member', 'viewer', 'guest']).withMessage('Invalid role specified'),

  body('message').optional().trim().isLength({ max: 500 }).withMessage('Message must not exceed 500 characters'),

  handleValidationErrors
];

// ==================== MEMBER ROLE VALIDATION ====================

export const validateMemberRoleUpdate = [body('role').isIn(['admin', 'manager', 'member', 'viewer', 'guest']).withMessage('Invalid role specified'), param('teamId').isMongoId().withMessage('Invalid team ID'), param('memberId').isMongoId().withMessage('Invalid member ID'), handleValidationErrors];
