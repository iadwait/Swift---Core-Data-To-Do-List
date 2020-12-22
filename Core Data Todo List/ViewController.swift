//
//  ViewController.swift
//  Core Data Todo List
//
//  Created by Adwait Barkale on 22/12/20.
//  Copyright © 2020 Adwait Barkale. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var models = [ToDoListItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Core Data Todo List"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(btnAddTapped))
        
        self.getAllItem()
    }
    
    @objc func btnAddTapped()
    {
        print("Add Tapped")
        let alert = UIAlertController(title: "New Item", message: "Enter New Item", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .cancel) { (_) in
            guard let field = alert.textFields?.first,let text = field.text,!text.isEmpty else {
                return
            }
            self.createItem(name: text)
        }
        
        alert.addAction(submitAction)
        present(alert,animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = models[indexPath.row]
        
        let sheet = UIAlertController(title: "Update or Delete Item", message: nil, preferredStyle: .actionSheet)
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel) { (_) in
            
        }
        let editAction = UIAlertAction(title: "Edit", style: .default) { (_) in
            //Show Alert with TextFields with refield data
            
            let alert = UIAlertController(title: "Edit Details", message: nil, preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields![0].text = item.name
            let updateAction = UIAlertAction(title: "Update", style: .default) { (_) in
                //Update Action with Core Data here
                
                guard let txtField = alert.textFields?.first,let newName = txtField.text,!newName.isEmpty else {
                    return
                }
                
                self.updateItem(item: item, newName: newName)
                
            }
            let cancleAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
            
            alert.addAction(updateAction)
            alert.addAction(cancleAction)
            self.present(alert,animated: true)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.deleteItem(item: item)
        }
        
        sheet.addAction(cancleAction)
        sheet.addAction(editAction)
        sheet.addAction(deleteAction)
        
        self.present(sheet,animated: true)
    }
    
    
    //MARK:- Core Data
    func getAllItem()
    {
        do{
            models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }catch{
            //Error
        }
    }
    
    func createItem(name: String)
    {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do{
            try context.save()
            getAllItem()
        }catch{
            
        }
    }

    func deleteItem(item: ToDoListItem)
    {
        context.delete(item)
        
        do{
            try context.save()
            getAllItem()
        }catch{
            
        }
    }
    
    func updateItem(item: ToDoListItem,newName: String)
    {
        item.name = newName
        
        do{
            try context.save()
            getAllItem()
        }catch{
            
        }
    }

}

