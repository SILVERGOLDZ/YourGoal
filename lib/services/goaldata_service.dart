import 'package:flutter/material.dart';

// MODEL UNTUK STEP (Langkah-langkah di dalam Detail Page)
// Ini sesuai dengan dummy data JSON yang kamu berikan
class StepModel {
  String title;
  String status;
  bool isCompleted;
  String description;
  List<String> subtasks;
  String message;

  StepModel({
    required this.title,
    required this.status,
    required this.isCompleted,
    required this.description,
    required this.subtasks,
    required this.message,
  });
}

// MODEL UNTUK ROADMAP (Card Utama di Halaman MyGoal)
class RoadmapModel {
  String title;
  String time;
  String status;
  String description; // Deskripsi umum roadmap
  List<StepModel> steps; // List langkah-langkah di dalamnya

  RoadmapModel({
    required this.title,
    required this.time,
    required this.status,
    required this.description,
    required this.steps,
  });

  // Hitung progress bar secara otomatis berdasarkan jumlah step yang selesai
  double get progress {
    if (steps.isEmpty) return 0.0;
    int completedCount = steps.where((s) => s.isCompleted).length;
    return completedCount / steps.length;
  }
}

// SERVICE SINGLETON (DATABASE SEMENTARA)
class GoalDataService {
  static final GoalDataService _instance = GoalDataService._internal();
  factory GoalDataService() => _instance;
  GoalDataService._internal();

  // DATA DUMMY AWAL (1 Roadmap berisi 4 Steps)
  final List<RoadmapModel> roadmaps = [
    RoadmapModel(
      title: "Menjadi Senior Product\nDesigner",
      time: "4 Tahun",
      status: "In Progress",
      description: "Perjalanan karir komprehensif dari memahami dasar desain hingga memimpin strategi produk di perusahaan teknologi besar.",
      steps: [
        StepModel(
          title: "Tahun 1: Membangun Pondasi Visual",
          status: "Complete",
          isCompleted: true,
          description: "Fokus pada penguasaan tools industri (Figma) dan prinsip dasar UI seperti tipografi, warna, dan layouting.",
          subtasks: [
            "Menyelesaikan Google UX Design Certificate",
            "Eksplorasi 100 hari UI Challenge",
            "Menguasai Auto Layout & Component Properties di Figma"
          ],
          message: "Jangan takut jelek di awal, kuantitas akan melahirkan kualitas.",
        ),
        StepModel(
          title: "Tahun 2: UX Research & Real Projects",
          status: "In Progress",
          isCompleted: false,
          description: "Mulai menangani masalah pengguna nyata, melakukan riset (User Interview, Usability Testing), dan magang.",
          subtasks: [
            "Magang di Startup Unicorn sebagai UI/UX Intern",
            "Membuat 3 Studi Kasus End-to-End untuk Portfolio",
            "Belajar Design System & Handover ke Developer"
          ],
          message: "Desain bukan cuma visual, tapi pemecahan masalah.",
        ),
        StepModel(
          title: "Tahun 3: Product Strategy & Leadership",
          status: "Not Started",
          isCompleted: false,
          description: "Memahami sisi bisnis dari produk, mentoring junior designer, dan memimpin inisiatif fitur baru.",
          subtasks: [
            "Mengambil peran Senior/Lead di project kantor",
            "Belajar dasar Product Management & Data Analytics",
            "Mentoring 5 Junior Designer"
          ],
          message: "Value kamu ada pada impact bisnis, bukan sekadar pixel.",
        ),
        StepModel(
          title: "Tahun 4: Principal Level Mastery",
          status: "Not Started",
          isCompleted: false,
          description: "Menjadi thought leader di industri, menulis buku/artikel, dan berbicara di konferensi internasional.",
          subtasks: [
            "Menjadi pembicara di Tech Conference Asia",
            "Menerbitkan buku tentang Desain Produk di Indonesia",
            "Membangun tim desain sendiri dari nol"
          ],
          message: "Legacy apa yang ingin kamu tinggalkan?",
        ),
      ],
    ),

    // --- ROADMAP 2: ENGINEERING PATH ---
    RoadmapModel(
      title: "Menjadi CTO / Tech Lead\nExpert",
      time: "5 Tahun",
      status: "In Progress",
      description: "Jalur karir teknikal untuk menguasai Software Engineering, System Architecture, hingga manajemen tim engineering skala besar.",
      steps: [
        StepModel(
          title: "Tahun 1: Fullstack Mastery",
          status: "Complete",
          isCompleted: true,
          description: "Menguasai satu stack teknologi secara mendalam (misal: Flutter + Firebase atau MERN Stack) hingga bisa membuat aplikasi kompleks sendirian.",
          subtasks: [
            "Membuat 5 Aplikasi Production-Ready di Play Store",
            "Menguasai State Management (BLoC/Riverpod) tingkat lanjut",
            "Paham Clean Architecture & SOLID Principles"
          ],
          message: "Coding itu seni logika, nikmati proses debugging-nya.",
        ),
        StepModel(
          title: "Tahun 2-3: System Design & Backend",
          status: "In Progress",
          isCompleted: false,
          description: "Belajar merancang sistem yang scalable, microservices, database optimization, dan cloud infrastructure (AWS/GCP).",
          subtasks: [
            "Sertifikasi AWS Solutions Architect Associate",
            "Implementasi CI/CD Pipeline & Docker/Kubernetes",
            "Belajar GoLang/Rust untuk High Performance Service"
          ],
          message: "Software Engineer yang hebat paham apa yang terjadi di balik layar.",
        ),
        StepModel(
          title: "Tahun 4: Engineering Management",
          status: "Not Started",
          isCompleted: false,
          description: "Transisi dari individual contributor menjadi manager. Fokus pada 'People', hiring, dan budaya engineering.",
          subtasks: [
            "Memimpin Squad berisi 8-10 Engineer",
            "Melakukan Code Review & Technical Planning mingguan",
            "Hiring & Onboarding talent baru"
          ],
          message: "Tugasmu sekarang adalah membuat timmu bersinar.",
        ),
        StepModel(
          title: "Tahun 5: CTO / Architect Role",
          status: "Not Started",
          isCompleted: false,
          description: "Bertanggung jawab atas visi teknologi perusahaan jangka panjang dan keputusan arsitektur krusial.",
          subtasks: [
            "Merancang arsitektur sistem untuk 5 Juta User",
            "Menjadi Tech Co-Founder di Startup Series B",
            "Investasi/Angel Investor di produk teknologi"
          ],
          message: "Dream big. The sky is not the limit.",
        ),
      ],
    ),
  ];

  void addRoadmap(RoadmapModel roadmap) {
    roadmaps.add(roadmap);
  }
}