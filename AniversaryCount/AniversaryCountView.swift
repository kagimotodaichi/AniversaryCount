//
//  ContentView.swift
//  AniversaryCount
//
//  Created by 鍵本大地 on 2025/11/12.
//

import SwiftUI

struct AniversaryCountView: View {
    @AppStorage("anniversary") private var anniversary: Date =
        Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 12))!
    @State private var now = Date()
    @State private var showingSettings = false
    
    // ⏰ 1秒ごとに更新するタイマー
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // 🎯 節目リスト（100日,200日,1年など）
    let milestones: [Int] = [100, 200, 300, 365, 730, 1095]
    
    // 💗 経過時間（日・時・分・秒）
    // ❗️←ここの中括弧が抜けてたので追加！
    var daysElapsed: DateComponents {
        Calendar.current.dateComponents([.day, .hour, .minute, .second],
                                        from: anniversary,
                                        to: now)
    } // ← ここを忘れると構文エラーになる！
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 🌈 背景グラデーション
                LinearGradient(
                    colors: [.purple.opacity(0.4), .red.opacity(0.4), .white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    
                    //経過時間の表示（1秒ごと更新）
                    Text(
                        String(
                            format: "記念日から\n %d日 %02d時間 %02d分 %02d秒",
                            (daysElapsed.day ?? 0) + 1,   // +1で「1日目」から表示
                            daysElapsed.hour ?? 0,
                            daysElapsed.minute ?? 0,
                            daysElapsed.second ?? 0
                        )
                    )
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.pink)
                    .padding(.top, 20)
                    .shadow(radius: 2)
                    .animation(.easeInOut(duration: 0.2), value: now)
                    
                    // 💫 節目リスト（100日、200日、1年など）
                    List(milestones, id: \.self) { milestone in
                        let target = Calendar.current.date(byAdding: .day, value: milestone, to: anniversary)!
                        let remain = Calendar.current.dateComponents([.day], from: now, to: target).day ?? 0
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(" \(milestone)日記念")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.purple)
                                Text(dateToJapaneseString(target))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(remain >= 0 ? "あと \(remain) 日" : "達成済 🎉")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(remain > 0 ? .pink : .gray)
                        }
                        .padding(.vertical, 6)
                    }
                    .scrollContentBackground(.hidden)
                    .cornerRadius(20)
                    .listStyle(.insetGrouped)
                }
                .navigationTitle("ふたりの記念日")
                .toolbar {
                    // ⚙️ 設定ボタン
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "heart.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(.pink)
                        }
                    }
                }
                .sheet(isPresented: $showingSettings) {
                    SettingView(anniversary: $anniversary)
                }
                // 🕒 1秒ごとに現在時刻を更新してUIを再描画
                .onReceive(timer) { now = $0 }
            }
        }
    }
}

//==================================================
// 🇯🇵 日本語日付フォーマット関数
//==================================================
func dateToJapaneseString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.dateFormat = "yyyy年M月d日（E）"
    return formatter.string(from: date)
}

//==================================================
// ⚙️ 設定画面（記念日変更用）
//==================================================
struct SettingView: View {
    @Binding var anniversary: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.white, .pink.opacity(0.15)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("記念日を変更")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.pink)
                    
                    // 🇯🇵 日本語カレンダー表示
                    DatePicker("記念日を選択", selection: $anniversary, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .datePickerStyle(.graphical)
                        .padding()
                        .background(.white.opacity(0.2))
                        .cornerRadius(16)
                    
                    Button("閉じる") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .padding(.top, 10)
                }
                .padding()
                .navigationTitle("設定")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    AniversaryCountView()
}
