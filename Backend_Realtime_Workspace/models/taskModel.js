import mongoose from 'mongoose';

const checklistItemSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    completed: { type: Boolean, default: false },
  },
  { _id: false }
);

const commentSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo', required: true },
    content: { type: String, required: true },
    createdAt: { type: Date, default: Date.now },
  },
  { _id: false }
);

const taskSchema = new mongoose.Schema(
  {
    title: { type: String, required: true },
    description: { type: String },
    assignedTo: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo' },
    projectId: { type: mongoose.Schema.Types.ObjectId, ref: 'Project', required: true },
    issueId: { type: mongoose.Schema.Types.ObjectId, ref: 'Issue' },
    statusquo: { type: String, enum: ['todo', 'in progress', 'done', 'blocked'], default: 'todo' },
    priority: { type: String, enum: ['low', 'medium', 'high'], default: 'medium' },
    checklist: [checklistItemSchema],
    comments: [commentSchema],
    dueDate: { type: Date },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'UserInfo', required: true },
    attachments: [{ type: String }], // File URLs
  },
  { timestamps: true }
);

const Task = mongoose.model('Task', taskSchema);

export default Task;
