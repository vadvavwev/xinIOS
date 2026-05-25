//
//  APIService.swift
//  EnterpriseApp
//
//  网络请求服务
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的URL"
        case .invalidResponse:
            return "无效的响应"
        case .unauthorized:
            return "未授权，请重新登录"
        case .serverError(let message):
            return message
        case .decodingError:
            return "数据解析失败"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

class APIService {
    static let shared = APIService()

    private let baseURL = "http://121.196.173.80:5000/api"

    private init() {}

    // MARK: - Generic Request

    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add auth token if required
        if requiresAuth, let token = KeychainService.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body if provided
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try JSONDecoder().decode(T.self, from: data)
                } catch {
                    print("Decoding error: \(error)")
                    throw APIError.decodingError
                }
            case 401:
                throw APIError.unauthorized
            default:
                if let errorResponse = try? JSONDecoder().decode(APIResponse<String>.self, from: data) {
                    throw APIError.serverError(errorResponse.message ?? "服务器错误")
                }
                throw APIError.serverError("服务器错误: \(httpResponse.statusCode)")
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Auth

    func login(username: String, password: String) async throws -> LoginResponse {
        let body = LoginRequest(username: username, password: password)
        let response: APIResponse<LoginResponse> = try await request(
            endpoint: "/auth/login",
            method: "POST",
            body: body,
            requiresAuth: false
        )

        guard let data = response.data else {
            throw APIError.serverError(response.message ?? "登录失败")
        }

        return data
    }

    // MARK: - Employees

    func getEmployees() async throws -> [Employee] {
        let response: APIResponse<[Employee]> = try await request(endpoint: "/employees")
        return response.data ?? []
    }

    func getEmployee(id: String) async throws -> Employee {
        let response: APIResponse<Employee> = try await request(endpoint: "/employees/\(id)")
        guard let data = response.data else {
            throw APIError.serverError("获取员工失败")
        }
        return data
    }

    func createEmployee(_ employee: EmployeeCreate) async throws -> Employee {
        let response: APIResponse<Employee> = try await request(
            endpoint: "/employees",
            method: "POST",
            body: employee
        )
        guard let data = response.data else {
            throw APIError.serverError("创建员工失败")
        }
        return data
    }

    func updateEmployee(id: String, employee: EmployeeUpdate) async throws -> Employee {
        let response: APIResponse<Employee> = try await request(
            endpoint: "/employees/\(id)",
            method: "PUT",
            body: employee
        )
        guard let data = response.data else {
            throw APIError.serverError("更新员工失败")
        }
        return data
    }

    func deleteEmployee(id: String) async throws {
        let _: APIResponse<String> = try await request(
            endpoint: "/employees/\(id)",
            method: "DELETE"
        )
    }

    // MARK: - Categories

    func getCategories() async throws -> [Category] {
        let response: APIResponse<[Category]> = try await request(endpoint: "/categories")
        return response.data ?? []
    }

    func getCategory(id: String) async throws -> Category {
        let response: APIResponse<Category> = try await request(endpoint: "/categories/\(id)")
        guard let data = response.data else {
            throw APIError.serverError("获取分类失败")
        }
        return data
    }

    func createCategory(_ category: CategoryCreate) async throws -> Category {
        let response: APIResponse<Category> = try await request(
            endpoint: "/categories",
            method: "POST",
            body: category
        )
        guard let data = response.data else {
            throw APIError.serverError("创建分类失败")
        }
        return data
    }

    func updateCategory(id: String, category: CategoryUpdate) async throws -> Category {
        let response: APIResponse<Category> = try await request(
            endpoint: "/categories/\(id)",
            method: "PUT",
            body: category
        )
        guard let data = response.data else {
            throw APIError.serverError("更新分类失败")
        }
        return data
    }

    func deleteCategory(id: String) async throws {
        let _: APIResponse<String> = try await request(
            endpoint: "/categories/\(id)",
            method: "DELETE"
        )
    }

    // MARK: - Devices

    func getDevices(categoryId: String) async throws -> [Device] {
        let response: APIResponse<[Device]> = try await request(
            endpoint: "/categories/\(categoryId)/devices"
        )
        return response.data ?? []
    }

    func getDevice(id: String) async throws -> Device {
        let response: APIResponse<Device> = try await request(endpoint: "/devices/\(id)")
        guard let data = response.data else {
            throw APIError.serverError("获取设备失败")
        }
        return data
    }

    func createDevice(_ device: DeviceCreate) async throws -> Device {
        let response: APIResponse<Device> = try await request(
            endpoint: "/devices",
            method: "POST",
            body: device
        )
        guard let data = response.data else {
            throw APIError.serverError("创建设备失败")
        }
        return data
    }

    func updateDevice(id: String, device: DeviceUpdate) async throws -> Device {
        let response: APIResponse<Device> = try await request(
            endpoint: "/devices/\(id)",
            method: "PUT",
            body: device
        )
        guard let data = response.data else {
            throw APIError.serverError("更新设备失败")
        }
        return data
    }

    func deleteDevice(id: String) async throws {
        let _: APIResponse<String> = try await request(
            endpoint: "/devices/\(id)",
            method: "DELETE"
        )
    }
}
