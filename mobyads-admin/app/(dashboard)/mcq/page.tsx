"use client";

import * as React from "react";
import {
  HelpCircle,
  Search,
  UploadCloud,
  FileCode,
  AlertCircle,
  CheckCircle2,
  Edit2,
  ChevronLeft,
  ChevronRight,
  Sparkles,
  RefreshCw,
  FileUp,
} from "lucide-react";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { StatusBadge } from "@/components/shared/StatusBadge";
import { EmptyState } from "@/components/shared/EmptyState";
import { Skeleton } from "@/components/ui/skeleton";
import { mockQuestions } from "@/lib/mock-data";
import {
  MCQQuestion,
  QuestionCategory,
  QuestionStatus,
} from "@/lib/types";
import { formatDate } from "@/lib/utils";

// Sample Test JSON containing valid questions and scattered non-consecutive errors (Row 2, Row 4, Row 6)
const SAMPLE_TEST_JSON_WITH_ERRORS = `[
  {
    "text": "What is the primary gas found in Earth's atmosphere?",
    "options": ["Oxygen", "Nitrogen", "Carbon Dioxide", "Hydrogen"],
    "correctIndex": 1,
    "category": "SCIENCE",
    "sourceName": "Atmospheric Science 101",
    "sourceDate": "2026-08-30"
  },
  {
    "text": "MALFORMED ROW 2: Options array has only 3 choices instead of 4",
    "options": ["Choice A", "Choice B", "Choice C"],
    "correctIndex": 0,
    "category": "GENERAL"
  },
  {
    "text": "Which programming language was developed by James Gosling at Sun Microsystems?",
    "options": ["Python", "Java", "C++", "Ruby"],
    "correctIndex": 1,
    "category": "TECH",
    "sourceName": "Computer History",
    "sourceDate": "2026-08-30"
  },
  {
    "text": "MALFORMED ROW 4: Out-of-bounds correctIndex",
    "options": ["Option 0", "Option 1", "Option 2", "Option 3"],
    "correctIndex": 9,
    "category": "TECH"
  },
  {
    "text": "Which company created the ChatGPT conversational AI model?",
    "options": ["Google", "Microsoft", "OpenAI", "Meta"],
    "correctIndex": 2,
    "category": "TECH",
    "sourceName": "AI Industry Brief",
    "sourceDate": "2026-08-30"
  },
  {
    "text": "",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctIndex": 0,
    "category": "GENERAL"
  },
  {
    "text": "Who is credited with inventing the World Wide Web in 1989?",
    "options": ["Tim Berners-Lee", "Alan Turing", "Vint Cerf", "Linus Torvalds"],
    "correctIndex": 0,
    "category": "TECH",
    "sourceName": "CERN Archives",
    "sourceDate": "2026-08-30"
  }
]`;

// Generator for a clean 500+ questions batch to test large file parsing performance
function generateLargeMockBatch(count = 500): string {
  const categories: QuestionCategory[] = [
    "TECH",
    "SCIENCE",
    "GENERAL",
    "BUSINESS",
    "SPORTS",
    "HISTORY",
    "CURRENT_AFFAIRS",
  ];
  const items = Array.from({ length: count }, (_, i) => {
    const num = i + 1;
    const cat = categories[num % categories.length];
    return {
      text: `Automated assessment benchmark question #${num}: What is the core theorem in ${cat.toLowerCase()}?`,
      options: [
        `Distractor option A for question #${num}`,
        `Verified standard correct choice B for question #${num}`,
        `Alternative distractor C for question #${num}`,
        `Secondary choice D for question #${num}`,
      ],
      correctIndex: 1,
      category: cat,
      sourceName: `Bulk Ingestion Volume ${Math.floor(num / 100) + 1}`,
      sourceDate: "2026-08-30",
    };
  });
  return JSON.stringify(items, null, 2);
}

interface ParseError {
  row: number;
  message: string;
}

export default function MCQPage() {
  const [questions, setQuestions] = React.useState<MCQQuestion[]>(mockQuestions);
  const [searchTerm, setSearchTerm] = React.useState("");
  const [categoryFilter, setCategoryFilter] = React.useState<string>("ALL");
  const [statusFilter, setStatusFilter] = React.useState<string>("ALL");
  const [page, setPage] = React.useState(1);
  const [isLoading, setIsLoading] = React.useState(false);
  const pageSize = 10;

  // Bulk Upload Dialog State
  const [isUploadOpen, setIsUploadOpen] = React.useState(false);
  const [uploadJsonText, setUploadJsonText] = React.useState("");
  const [parsedValidQuestions, setParsedValidQuestions] = React.useState<MCQQuestion[]>([]);
  const [parseErrors, setParseErrors] = React.useState<ParseError[]>([]);
  const [duplicateCount, setDuplicateCount] = React.useState(0);
  const [skipDuplicates, setSkipDuplicates] = React.useState(true);
  const [hasParsed, setHasParsed] = React.useState(false);
  const [showSchemaHint, setShowSchemaHint] = React.useState(false);
  const [isDragging, setIsDragging] = React.useState(false);

  // Single Question Edit Dialog State
  const [editingQuestion, setEditingQuestion] = React.useState<MCQQuestion | null>(null);

  // Toast Notification State
  const [toastMessage, setToastMessage] = React.useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  // Simulate loading state
  const handleRefresh = () => {
    setIsLoading(true);
    setTimeout(() => setIsLoading(false), 450);
  };

  // Filter questions
  const filteredQuestions = React.useMemo(() => {
    return questions.filter((q) => {
      const matchesSearch =
        !searchTerm.trim() ||
        q.text.toLowerCase().includes(searchTerm.toLowerCase().trim()) ||
        q.options.some((opt) => opt.toLowerCase().includes(searchTerm.toLowerCase().trim()));

      const matchesCategory =
        categoryFilter === "ALL" || q.category === categoryFilter;

      const matchesStatus =
        statusFilter === "ALL" || q.status === statusFilter;

      return matchesSearch && matchesCategory && matchesStatus;
    });
  }, [questions, searchTerm, categoryFilter, statusFilter]);

  // Pagination
  const totalPages = Math.ceil(filteredQuestions.length / pageSize) || 1;
  const paginatedQuestions = filteredQuestions.slice(
    (page - 1) * pageSize,
    page * pageSize
  );

  // Bulk Upload Parsing & Validation logic
  const handleParseJson = React.useCallback(
    (jsonString: string) => {
      setHasParsed(true);
      const errors: ParseError[] = [];
      const validItems: MCQQuestion[] = [];
      let dupes = 0;

      const trimmedInput = jsonString.trim();
      if (!trimmedInput) {
        setParseErrors([{ row: 0, message: "JSON content is empty." }]);
        setParsedValidQuestions([]);
        setDuplicateCount(0);
        return;
      }

      try {
        const data: unknown = JSON.parse(trimmedInput);

        if (!Array.isArray(data)) {
          setParseErrors([
            { row: 0, message: "Root JSON must be an array of question objects (e.g. `[{ ... }]`)." },
          ]);
          setParsedValidQuestions([]);
          setDuplicateCount(0);
          return;
        }

        if (data.length === 0) {
          setParseErrors([
            { row: 0, message: "JSON array is empty (0 questions found in file)." },
          ]);
          setParsedValidQuestions([]);
          setDuplicateCount(0);
          return;
        }

        // Track seen question texts to handle de-duplication
        const seenTexts = new Set(
          questions.map((q) => q.text.trim().toLowerCase())
        );

        (data as unknown[]).forEach((raw: unknown, index: number) => {
          // Exactly 1-indexed row number matching JSON array position
          const rowNum = index + 1;
          const item =
            typeof raw === "object" && raw !== null
              ? (raw as Record<string, unknown>)
              : null;

          if (!item) {
            errors.push({ row: rowNum, message: "Item is not a valid JSON object." });
            return;
          }

          // Validate question text
          const textRaw = item["text"] ?? item["question"];
          if (typeof textRaw !== "string" || textRaw.trim().length === 0) {
            errors.push({ row: rowNum, message: "Question 'text' is missing or empty." });
            return;
          }
          const text = textRaw.trim();

          // Validate options
          const optionsRaw = item["options"];
          if (!Array.isArray(optionsRaw)) {
            errors.push({ row: rowNum, message: "'options' must be an array of 4 strings." });
            return;
          }
          if (optionsRaw.length !== 4) {
            errors.push({
              row: rowNum,
              message: `'options' must contain exactly 4 items (found ${optionsRaw.length}).`,
            });
            return;
          }
          if (
            optionsRaw.some(
              (opt: unknown) => typeof opt !== "string" || opt.trim().length === 0
            )
          ) {
            errors.push({
              row: rowNum,
              message: "All 4 options must be non-empty strings.",
            });
            return;
          }
          const options = (optionsRaw as string[]).map((o) => o.trim());

          // Validate correctIndex
          const correctIndex: unknown = item["correctIndex"];
          if (
            typeof correctIndex !== "number" ||
            !Number.isInteger(correctIndex) ||
            correctIndex < 0 ||
            correctIndex > 3
          ) {
            errors.push({
              row: rowNum,
              message: `'correctIndex' must be an integer between 0 and 3 (got ${String(correctIndex)}).`,
            });
            return;
          }

          // Check duplication
          const normalizedText = text.toLowerCase();
          if (seenTexts.has(normalizedText)) {
            dupes++;
            if (skipDuplicates) {
              return; // Skip duplicate question
            }
          } else {
            seenTexts.add(normalizedText);
          }

          // Validate category
          const category = String(item["category"] ?? "GENERAL").toUpperCase();
          const sourceName =
            typeof item["sourceName"] === "string" && item["sourceName"].trim()
              ? item["sourceName"].trim()
              : "Bulk Ingestion";
          const sourceDate =
            typeof item["sourceDate"] === "string" && item["sourceDate"].trim()
              ? item["sourceDate"].trim()
              : new Date().toISOString().split("T")[0];

          validItems.push({
            id: `mcq_imp_${Date.now()}_${index}`,
            text,
            options,
            correctIndex,
            category: category as QuestionCategory,
            status: "ACTIVE",
            sourceName,
            sourceDate,
            expiresAt: typeof item["expiresAt"] === "string" ? item["expiresAt"] : null,
            timesAnswered: 0,
            correctRate: 0,
            createdAt: new Date().toISOString(),
          });
        });

        setParseErrors(errors);
        setParsedValidQuestions(validItems);
        setDuplicateCount(dupes);
      } catch (e: unknown) {
        const message = e instanceof Error ? e.message : String(e);
        setParseErrors([{ row: 0, message: `Invalid JSON syntax: ${message}` }]);
        setParsedValidQuestions([]);
        setDuplicateCount(0);
      }
    },
    [questions, skipDuplicates]
  );

  const handleFileDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragging(false);
    const file = e.dataTransfer.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const content = event.target?.result as string;
      setUploadJsonText(content);
      handleParseJson(content);
    };
    reader.readAsText(file);
  };

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const content = event.target?.result as string;
      setUploadJsonText(content);
      handleParseJson(content);
    };
    reader.readAsText(file);
  };

  const handleConfirmImport = () => {
    if (parsedValidQuestions.length === 0) return;

    setQuestions((prev) => [...parsedValidQuestions, ...prev]);
    setIsUploadOpen(false);
    setUploadJsonText("");
    setParsedValidQuestions([]);
    setParseErrors([]);
    setHasParsed(false);
    showToast(`Successfully imported ${parsedValidQuestions.length} questions into the bank!`);
  };

  // Save single edited question
  const handleSaveEditedQuestion = (updated: MCQQuestion) => {
    setQuestions((prev) =>
      prev.map((q) => (q.id === updated.id ? updated : q))
    );
    setEditingQuestion(null);
    showToast(`Question #${updated.id} saved successfully.`);
  };

  return (
    <div className="space-y-6">
      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-5 right-5 z-50 flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-3 text-xs font-semibold text-white shadow-xl animate-in slide-in-from-bottom-5">
          <CheckCircle2 className="h-4 w-4 text-emerald-400" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">
              MCQ Question Bank
            </h1>
            <span className="rounded-full bg-blue-50 px-2.5 py-0.5 text-xs font-bold text-blue-700 border border-blue-200">
              {questions.length} questions
            </span>
          </div>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Curate, edit, and bulk-import multiple-choice questions for the continuous 24/7 task pipeline.
          </p>
        </div>

        <div className="flex items-center gap-2.5">
          <Button
            variant="outline"
            size="sm"
            onClick={handleRefresh}
            className="h-9 px-3 text-xs"
            title="Refresh question pool"
          >
            <RefreshCw className="h-3.5 w-3.5 mr-1 text-slate-500" />
            Sync
          </Button>

          <Button
            size="sm"
            onClick={() => {
              setIsUploadOpen(true);
              setUploadJsonText("");
              setParsedValidQuestions([]);
              setParseErrors([]);
              setHasParsed(false);
            }}
            className="h-9 bg-blue-600 hover:bg-blue-700 font-semibold text-xs text-white shadow-xs"
          >
            <UploadCloud className="mr-2 h-4 w-4" />
            Upload Questions (JSON)
          </Button>
        </div>
      </div>

      {/* Search & Filters Bar */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 bg-white p-3 rounded-xl border border-slate-200 shadow-2xs">
        {/* Search Field */}
        <div className="relative flex-1">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Search questions or answer options..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              setPage(1);
            }}
            className="pl-9 h-9 text-xs sm:text-sm border-slate-200"
          />
        </div>

        {/* Filter Dropdowns */}
        <div className="flex items-center gap-2">
          {/* Category Filter */}
          <Select
            value={categoryFilter}
            onValueChange={(val) => {
              setCategoryFilter(val);
              setPage(1);
            }}
          >
            <SelectTrigger className="w-[150px] h-9 text-xs">
              <SelectValue placeholder="Category" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">All Categories</SelectItem>
              <SelectItem value="TECH">Technology</SelectItem>
              <SelectItem value="SCIENCE">Science</SelectItem>
              <SelectItem value="GENERAL">General Knowledge</SelectItem>
              <SelectItem value="BUSINESS">Business & Finance</SelectItem>
              <SelectItem value="SPORTS">Sports</SelectItem>
              <SelectItem value="HISTORY">History</SelectItem>
              <SelectItem value="CURRENT_AFFAIRS">Current Affairs</SelectItem>
            </SelectContent>
          </Select>

          {/* Status Filter */}
          <Select
            value={statusFilter}
            onValueChange={(val) => {
              setStatusFilter(val);
              setPage(1);
            }}
          >
            <SelectTrigger className="w-[140px] h-9 text-xs">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="ALL">All Statuses</SelectItem>
              <SelectItem value="ACTIVE">Active</SelectItem>
              <SelectItem value="PENDING_REVIEW">Pending Review</SelectItem>
              <SelectItem value="RETIRED">Retired</SelectItem>
            </SelectContent>
          </Select>

          {(searchTerm || categoryFilter !== "ALL" || statusFilter !== "ALL") && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => {
                setSearchTerm("");
                setCategoryFilter("ALL");
                setStatusFilter("ALL");
                setPage(1);
              }}
              className="h-9 px-2 text-xs text-slate-500 hover:text-slate-900"
            >
              Reset
            </Button>
          )}
        </div>
      </div>

      {/* QUESTION LIST TABLE */}
      <div className="rounded-xl border border-slate-200 bg-white overflow-hidden shadow-2xs">
        {isLoading ? (
          <div className="p-6 space-y-4">
            <div className="space-y-3">
              <Skeleton className="h-8 w-full" />
              <Skeleton className="h-12 w-full" />
              <Skeleton className="h-12 w-full" />
              <Skeleton className="h-12 w-full" />
              <Skeleton className="h-12 w-full" />
            </div>
          </div>
        ) : paginatedQuestions.length === 0 ? (
          <EmptyState
            icon={HelpCircle}
            title="No questions found"
            description="Try changing your search term or filters, or upload a new JSON batch."
          />
        ) : (
          <Table>
            <TableHeader>
              <TableRow className="bg-slate-50/75">
                <TableHead className="font-semibold text-slate-600 w-[50%]">Question Statement & Correct Answer</TableHead>
                <TableHead className="font-semibold text-slate-600">Category</TableHead>
                <TableHead className="font-semibold text-slate-600">Status</TableHead>
                <TableHead className="font-semibold text-slate-600">Source & Date</TableHead>
                <TableHead className="font-semibold text-slate-600 text-center w-[80px]">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {paginatedQuestions.map((q) => (
                <TableRow
                  key={q.id}
                  onClick={() => setEditingQuestion(q)}
                  className="cursor-pointer hover:bg-slate-50/80 transition-colors"
                >
                  {/* Truncated Question Text with Correct Answer Indicator */}
                  <TableCell>
                    <div className="space-y-1">
                      <div className="font-semibold text-slate-900 line-clamp-2 text-sm leading-snug">
                        {q.text}
                      </div>
                      <div className="flex items-center gap-1.5 text-xs text-emerald-700 font-medium">
                        <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 shrink-0" />
                        <span className="line-clamp-1">
                          Correct: {q.options[q.correctIndex]}
                        </span>
                      </div>
                    </div>
                  </TableCell>

                  {/* Category Badge */}
                  <TableCell>
                    <StatusBadge status={q.category} />
                  </TableCell>

                  {/* Status Badge */}
                  <TableCell>
                    <StatusBadge status={q.status} />
                  </TableCell>

                  {/* Source Date */}
                  <TableCell>
                    <div className="space-y-0.5">
                      <div className="text-xs text-slate-700 font-medium">
                        {formatDate(q.sourceDate)}
                      </div>
                      <div className="text-[11px] text-slate-400 truncate max-w-[140px]">
                        {q.sourceName || "Editorial"}
                      </div>
                    </div>
                  </TableCell>

                  {/* Action button */}
                  <TableCell className="text-center" onClick={(e) => e.stopPropagation()}>
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => setEditingQuestion(q)}
                      className="h-8 w-8 text-slate-400 hover:text-slate-900"
                      title="Edit question"
                    >
                      <Edit2 className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </div>

      {/* Pagination Footer */}
      {!isLoading && totalPages > 1 && (
        <div className="flex items-center justify-between px-2 pt-1">
          <p className="text-xs text-slate-500 font-medium">
            Showing {(page - 1) * pageSize + 1}–{Math.min(page * pageSize, filteredQuestions.length)} of{" "}
            {filteredQuestions.length} questions
          </p>
          <div className="flex items-center space-x-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage((p) => Math.max(1, p - 1))}
              disabled={page === 1}
              className="h-8 px-2.5 text-xs"
            >
              <ChevronLeft className="h-4 w-4 mr-1" /> Prev
            </Button>
            <span className="text-xs font-semibold text-slate-700 px-2">
              {page} / {totalPages}
            </span>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
              disabled={page === totalPages}
              className="h-8 px-2.5 text-xs"
            >
              Next <ChevronRight className="h-4 w-4 ml-1" />
            </Button>
          </div>
        </div>
      )}

      {/* BULK UPLOAD DIALOG */}
      <Dialog open={isUploadOpen} onOpenChange={setIsUploadOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto p-6">
          <DialogHeader className="pb-2 border-b border-slate-100">
            <div className="flex items-center gap-2">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-blue-50 text-blue-600">
                <UploadCloud className="h-4 w-4" />
              </div>
              <div>
                <DialogTitle className="text-lg font-bold text-slate-900">
                  Bulk Upload Questions
                </DialogTitle>
                <DialogDescription className="text-xs text-slate-500">
                  Import batches of multiple-choice questions via JSON format.
                </DialogDescription>
              </div>
            </div>
          </DialogHeader>

          <div className="space-y-4 pt-2">
            {/* Schema Hint Accordion */}
            <div className="rounded-lg border border-slate-200 bg-slate-50/70 p-3">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2 text-xs font-bold text-slate-800">
                  <FileCode className="h-4 w-4 text-blue-600" />
                  Expected JSON Schema Format
                </div>
                <button
                  type="button"
                  onClick={() => setShowSchemaHint(!showSchemaHint)}
                  className="text-xs text-blue-600 hover:underline font-medium cursor-pointer"
                >
                  {showSchemaHint ? "Hide example" : "View schema example"}
                </button>
              </div>

              {showSchemaHint && (
                <div className="mt-3 pt-2 border-t border-slate-200">
                  <pre className="text-[11px] font-mono bg-slate-900 text-slate-100 p-3 rounded-md overflow-x-auto leading-relaxed">
{`[
  {
    "text": "What is the capital of France?",
    "options": ["Berlin", "Madrid", "Paris", "Rome"],
    "correctIndex": 2,
    "category": "GENERAL",
    "sourceName": "Atlas",
    "sourceDate": "2026-08-30",
    "expiresAt": null
  }
]`}
                  </pre>
                  <p className="text-[11px] text-slate-500 mt-2">
                    • <code>options</code> must be an array of exactly 4 non-empty strings.<br />
                    • <code>correctIndex</code> must be an integer from 0 to 3.<br />
                    • <code>category</code>: TECH, SCIENCE, GENERAL, BUSINESS, SPORTS, HISTORY, CURRENT_AFFAIRS.
                  </p>
                </div>
              )}
            </div>

            {/* Drag & Drop File Zone & Quick Test Buttons */}
            <div className="space-y-2">
              <div className="flex flex-wrap items-center justify-between gap-2">
                <Label className="text-xs font-semibold text-slate-700">
                  Select File or Paste JSON
                </Label>
                <div className="flex items-center gap-2">
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      setUploadJsonText(SAMPLE_TEST_JSON_WITH_ERRORS);
                      handleParseJson(SAMPLE_TEST_JSON_WITH_ERRORS);
                    }}
                    className="h-7 text-[11px] text-amber-700 border-amber-200 bg-amber-50/50 hover:bg-amber-100 cursor-pointer"
                  >
                    <AlertCircle className="h-3 w-3 mr-1" />
                    Load Sample (with 3 errors)
                  </Button>

                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      const largeJson = generateLargeMockBatch(500);
                      setUploadJsonText(largeJson);
                      handleParseJson(largeJson);
                    }}
                    className="h-7 text-[11px] text-blue-700 border-blue-200 bg-blue-50/50 hover:bg-blue-100 cursor-pointer"
                  >
                    <Sparkles className="h-3 w-3 mr-1" />
                    Load 500+ Batch
                  </Button>
                </div>
              </div>

              {/* Drag and Drop Zone */}
              <div
                onDragOver={(e) => {
                  e.preventDefault();
                  setIsDragging(true);
                }}
                onDragLeave={() => setIsDragging(false)}
                onDrop={handleFileDrop}
                className={`flex flex-col items-center justify-center w-full h-28 border-2 border-dashed rounded-xl cursor-pointer transition-colors ${
                  isDragging
                    ? "border-blue-500 bg-blue-50/60"
                    : "border-slate-300 bg-slate-50/50 hover:bg-slate-100/70"
                }`}
              >
                <label className="flex flex-col items-center justify-center w-full h-full cursor-pointer">
                  <div className="flex flex-col items-center justify-center pt-2 pb-2">
                    <FileUp className={`w-7 h-7 mb-1.5 ${isDragging ? "text-blue-600" : "text-slate-400"}`} />
                    <p className="text-xs text-slate-600 font-medium">
                      <span className="font-semibold text-blue-600">Click to browse</span> or drag and drop .json file
                    </p>
                    <p className="text-[11px] text-slate-400 mt-0.5">UTF-8 Encoded JSON Array</p>
                  </div>
                  <input
                    type="file"
                    accept=".json,application/json"
                    className="hidden"
                    onChange={handleFileUpload}
                  />
                </label>
              </div>

              <Textarea
                placeholder="Or paste JSON directly here..."
                value={uploadJsonText}
                onChange={(e) => {
                  setUploadJsonText(e.target.value);
                  handleParseJson(e.target.value);
                }}
                className="font-mono text-xs h-24 border-slate-200"
              />
            </div>

            {/* Parsing Validation Summary Banner */}
            {hasParsed && (
              <div className="space-y-3">
                <label className="flex items-center gap-2 text-xs font-medium text-slate-700 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={skipDuplicates}
                    onChange={(e) => {
                      setSkipDuplicates(e.target.checked);
                      if (uploadJsonText.trim()) handleParseJson(uploadJsonText);
                    }}
                    className="h-3.5 w-3.5 rounded border-slate-300 text-blue-600"
                  />
                  Skip duplicate questions on import
                </label>
                <div className="flex items-center justify-between p-3 rounded-lg border bg-slate-50 border-slate-200 text-xs">
                  <div className="flex items-center gap-2">
                    <span
                      className={`flex h-2 w-2 rounded-full ${
                        parsedValidQuestions.length > 0 ? "bg-emerald-500" : "bg-red-500"
                      }`}
                    />
                    <span className="font-semibold text-slate-800">
                      {parsedValidQuestions.length} questions ready to import
                    </span>
                    {duplicateCount > 0 && (
                      <span className="text-slate-500 text-[11px]">
                        ({duplicateCount} duplicates skipped)
                      </span>
                    )}
                  </div>

                  {parseErrors.length > 0 && (
                    <div className="flex items-center gap-1.5 font-bold text-red-700 bg-red-50 px-2 py-0.5 rounded border border-red-200">
                      <AlertCircle className="h-3.5 w-3.5" />
                      {parseErrors.length} invalid rows flagged
                    </div>
                  )}
                </div>

                {/* Error Box Listing Specific Row Issues */}
                {parseErrors.length > 0 && (
                  <div className="rounded-lg border border-red-200 bg-red-50/70 p-3 space-y-1.5">
                    <div className="flex items-center gap-1.5 text-xs font-bold text-red-800">
                      <AlertCircle className="h-4 w-4" />
                      Validation Errors in Input:
                    </div>
                    <ul className="text-xs text-red-700 space-y-1 pl-5 list-disc max-h-36 overflow-y-auto">
                      {parseErrors.map((err, idx) => (
                        <li key={idx} className="font-mono text-[11px]">
                          {err.row > 0 ? <strong className="font-semibold">Row {err.row}: </strong> : ""}
                          <span className="font-sans">{err.message}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                )}

                {/* Preview Table of Parsed Questions */}
                {parsedValidQuestions.length > 0 && (
                  <div className="space-y-2">
                    <div className="text-xs font-bold text-slate-800">
                      Preview of Valid Questions (Showing first {Math.min(10, parsedValidQuestions.length)} of {parsedValidQuestions.length}):
                    </div>
                    <div className="rounded-xl border border-slate-200 overflow-hidden bg-white shadow-2xs max-h-52 overflow-y-auto">
                      <Table>
                        <TableHeader>
                          <TableRow className="bg-slate-50/75">
                            <TableHead className="text-xs font-semibold text-slate-600">Question Statement</TableHead>
                            <TableHead className="text-xs font-semibold text-slate-600">Category</TableHead>
                            <TableHead className="text-xs font-semibold text-slate-600">Correct Answer</TableHead>
                          </TableRow>
                        </TableHeader>
                        <TableBody>
                          {parsedValidQuestions.slice(0, 10).map((item, idx) => (
                            <TableRow key={idx}>
                              <TableCell className="text-xs font-medium text-slate-800 max-w-xs truncate">
                                {item.text}
                              </TableCell>
                              <TableCell className="text-xs">
                                <StatusBadge status={item.category} />
                              </TableCell>
                              <TableCell className="text-xs text-emerald-700 font-semibold truncate">
                                {item.options[item.correctIndex]}
                              </TableCell>
                            </TableRow>
                          ))}
                        </TableBody>
                      </Table>
                    </div>
                  </div>
                )}
              </div>
            )}
          </div>

          <DialogFooter className="pt-4 border-t border-slate-100 gap-2">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setIsUploadOpen(false)}
              className="text-xs"
            >
              Cancel
            </Button>
            <Button
              type="button"
              size="sm"
              onClick={handleConfirmImport}
              disabled={parsedValidQuestions.length === 0}
              className="bg-blue-600 hover:bg-blue-700 font-semibold text-xs text-white"
            >
              Confirm Import ({parsedValidQuestions.length} Questions)
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* SINGLE QUESTION EDIT DIALOG */}
      {editingQuestion && (
        <EditQuestionDialog
          question={editingQuestion}
          onClose={() => setEditingQuestion(null)}
          onSave={handleSaveEditedQuestion}
        />
      )}
    </div>
  );
}

// Subcomponent for Question Editing
interface EditQuestionDialogProps {
  question: MCQQuestion;
  onClose: () => void;
  onSave: (updated: MCQQuestion) => void;
}

function EditQuestionDialog({
  question,
  onClose,
  onSave,
}: EditQuestionDialogProps) {
  const [text, setText] = React.useState(question.text);
  const [options, setOptions] = React.useState<string[]>([...question.options]);
  const [correctIndex, setCorrectIndex] = React.useState<number>(question.correctIndex);
  const [category, setCategory] = React.useState<QuestionCategory>(question.category);
  const [status, setStatus] = React.useState<QuestionStatus>(question.status);
  const [sourceName, setSourceName] = React.useState(question.sourceName || "");
  const [sourceDate, setSourceDate] = React.useState(question.sourceDate || "");

  const handleOptionChange = (idx: number, val: string) => {
    const next = [...options];
    next[idx] = val;
    setOptions(next);
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    if (!text.trim() || options.some((o) => !o.trim())) return;

    onSave({
      ...question,
      text: text.trim(),
      options: options.map((o) => o.trim()),
      correctIndex,
      category,
      status,
      sourceName: sourceName.trim(),
      sourceDate: sourceDate.trim(),
    });
  };

  return (
    <Dialog open={Boolean(question)} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="max-w-xl max-h-[90vh] overflow-y-auto p-6">
        <form onSubmit={handleSave} className="space-y-4">
          <DialogHeader className="pb-2 border-b border-slate-100">
            <div className="flex items-center justify-between">
              <div>
                <DialogTitle className="text-base font-bold text-slate-900">
                  Edit MCQ Question
                </DialogTitle>
                <DialogDescription className="text-xs text-slate-400 font-mono mt-0.5">
                  ID: {question.id}
                </DialogDescription>
              </div>
              <StatusBadge status={status} />
            </div>
          </DialogHeader>

          {/* Question Text */}
          <div className="space-y-1.5">
            <Label className="text-xs font-semibold text-slate-700">Question Statement</Label>
            <Textarea
              value={text}
              onChange={(e) => setText(e.target.value)}
              required
              rows={3}
              className="text-xs sm:text-sm border-slate-200"
            />
          </div>

          {/* 4 Options with Radio Correct Answer Selector */}
          <div className="space-y-2">
            <Label className="text-xs font-semibold text-slate-700">
              Answer Options (Select the correct radio button)
            </Label>
            <div className="space-y-2">
              {options.map((opt, idx) => {
                const letter = String.fromCharCode(65 + idx);
                const isCorrect = correctIndex === idx;

                return (
                  <div
                    key={idx}
                    className={`flex items-center gap-2.5 p-2 rounded-lg border transition-colors ${
                      isCorrect
                        ? "border-emerald-300 bg-emerald-50/50"
                        : "border-slate-200 bg-white"
                    }`}
                  >
                    <input
                      type="radio"
                      name="correct_answer"
                      id={`opt_${idx}`}
                      checked={isCorrect}
                      onChange={() => setCorrectIndex(idx)}
                      className="h-4 w-4 text-emerald-600 focus:ring-emerald-500 cursor-pointer"
                    />
                    <label
                      htmlFor={`opt_${idx}`}
                      className={`text-xs font-bold w-5 cursor-pointer ${
                        isCorrect ? "text-emerald-800" : "text-slate-500"
                      }`}
                    >
                      {letter}.
                    </label>
                    <Input
                      value={opt}
                      onChange={(e) => handleOptionChange(idx, e.target.value)}
                      required
                      placeholder={`Option ${letter}`}
                      className="h-8 text-xs flex-1 border-slate-200 bg-white"
                    />
                    {isCorrect && (
                      <span className="text-[10px] font-bold text-emerald-700 uppercase tracking-wider pr-1">
                        Correct
                      </span>
                    )}
                  </div>
                );
              })}
            </div>
          </div>

          {/* Category & Status Row */}
          <div className="grid grid-cols-2 gap-3 pt-1">
            <div className="space-y-1.5">
              <Label className="text-xs font-semibold text-slate-700">Category</Label>
              <Select
                value={category}
                onValueChange={(val) => setCategory(val as QuestionCategory)}
              >
                <SelectTrigger className="h-9 text-xs">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="TECH">Technology</SelectItem>
                  <SelectItem value="SCIENCE">Science</SelectItem>
                  <SelectItem value="GENERAL">General Knowledge</SelectItem>
                  <SelectItem value="BUSINESS">Business & Finance</SelectItem>
                  <SelectItem value="SPORTS">Sports</SelectItem>
                  <SelectItem value="HISTORY">History</SelectItem>
                  <SelectItem value="CURRENT_AFFAIRS">Current Affairs</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-1.5">
              <Label className="text-xs font-semibold text-slate-700">Status</Label>
              <Select
                value={status}
                onValueChange={(val) => setStatus(val as QuestionStatus)}
              >
                <SelectTrigger className="h-9 text-xs">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="ACTIVE">Active</SelectItem>
                  <SelectItem value="PENDING_REVIEW">Pending Review</SelectItem>
                  <SelectItem value="RETIRED">Retired</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Source Metadata */}
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-1.5">
              <Label className="text-xs font-semibold text-slate-700">Source Name</Label>
              <Input
                value={sourceName}
                onChange={(e) => setSourceName(e.target.value)}
                placeholder="e.g. Wikipedia / NCERT"
                className="h-8 text-xs"
              />
            </div>
            <div className="space-y-1.5">
              <Label className="text-xs font-semibold text-slate-700">Source Date</Label>
              <Input
                type="date"
                value={sourceDate}
                onChange={(e) => setSourceDate(e.target.value)}
                className="h-8 text-xs"
              />
            </div>
          </div>

          <DialogFooter className="pt-4 border-t border-slate-100 gap-2">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={onClose}
              className="text-xs"
            >
              Cancel
            </Button>
            <Button
              type="submit"
              size="sm"
              className="bg-blue-600 hover:bg-blue-700 text-white font-semibold text-xs"
            >
              Save Changes
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
