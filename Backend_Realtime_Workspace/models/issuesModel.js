import mongoose from 'mongoose';

const commentSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo', required: true },
    content: { type: String, required: true },
    createdAt: { type: Date, default: Date.now }
  },
  { _id: false }
);

const issueSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    description: { type: String },
    projectId: { type: mongoose.Schema.Types.ObjectId, ref: 'Project', required: true },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo', required: true },
    assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo' },
    priority: { type: String, enum: ['low', 'medium', 'high', 'critical'], default: 'medium' },
    statusquo: { type: String, enum: ['open', 'in progress', 'resolved', 'closed'], default: 'open' },
    tags: [{ type: String }],
    comments: [commentSchema],
    attachments: [{ type: String }], // File URLs
    dueDate: { type: Date }
  },
  { timestamps: true }
);

const Issue = mongoose.model('Issue', issueSchema);

export default Issue;
