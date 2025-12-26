import { Trophy, Users, Calendar, Settings } from "lucide-react";

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900">
      <div className="container mx-auto px-4 py-16">
        <div className="text-center mb-16">
          <h1 className="text-5xl font-bold text-white mb-4">
            Tournament Manager
          </h1>
          <p className="text-xl text-gray-300 max-w-2xl mx-auto">
            Професійна система управління турнірами з бойових мистецтв.
            Створюйте, керуйте та проводьте змагання з легкістю.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8 mb-16">
          <div className="bg-gray-800 rounded-lg p-6 text-center hover:bg-gray-700 transition-colors">
            <Trophy className="w-12 h-12 text-yellow-500 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-white mb-2">Турніри</h3>
            <p className="text-gray-400">Створюйте та керуйте змаганнями</p>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 text-center hover:bg-gray-700 transition-colors">
            <Users className="w-12 h-12 text-blue-500 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-white mb-2">Учасники</h3>
            <p className="text-gray-400">Керуйте спортсменами та командами</p>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 text-center hover:bg-gray-700 transition-colors">
            <Calendar className="w-12 h-12 text-green-500 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-white mb-2">Розклад</h3>
            <p className="text-gray-400">Плануйте поєдинки та раунди</p>
          </div>

          <div className="bg-gray-800 rounded-lg p-6 text-center hover:bg-gray-700 transition-colors">
            <Settings className="w-12 h-12 text-purple-500 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-white mb-2">Налаштування</h3>
            <p className="text-gray-400">Налаштуйте систему під свої потреби</p>
          </div>
        </div>

        <div className="text-center">
          <div className="bg-gray-800 rounded-lg p-8 max-w-2xl mx-auto">
            <h2 className="text-2xl font-bold text-white mb-4">
              Почніть роботу
            </h2>
            <p className="text-gray-300 mb-6">
              Щоб розпочати, налаштуйте змінні середовища та підключіть базу даних Supabase.
              Далі ви зможете імпортувати дані з існуючої системи.
            </p>
            <div className="text-sm text-gray-400">
              <p>Статус: Підготовка до міграції</p>
              <p>Next.js + Supabase + TypeScript</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
