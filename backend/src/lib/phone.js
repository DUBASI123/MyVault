export function normalizePhone(raw) {
  const trimmed = String(raw ?? '').trim();
  if (trimmed.includes('@')) return trimmed;

  const digits = trimmed.replace(/\D/g, '');
  if (trimmed.startsWith('+')) return `+${digits}`;
  if (digits.length === 10) return `+91${digits}`;
  if (digits.startsWith('91') && digits.length === 12) return `+${digits}`;
  if (digits.length > 0) return `+${digits}`;
  return trimmed;
}

export function isEmailTarget(target) {
  return String(target).includes('@');
}
